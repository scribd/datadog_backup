# frozen_string_literal: true

require 'diffy'
require 'deepsort'
require 'faraday'
require 'faraday/retry'

module DatadogBackup
  # The default options for backing up and restores.
  # This base class is meant to be extended by specific resources, such as Dashboards, Monitors, and so on.
  class Resources
    ##
    # Class variables and methods
    include LocalFilesystem

    class <<self
      @api_version = 'v1'
      @api_resource_name = nil
      @id_keyname = 'id'
      @banlist = %w[].freeze

      def new_resource(id = nil, body = nil)
        raise ArgumentError, 'id and body cannot both be nil' if id.nil? && body.nil?

        new(
          id: id,
          body: body,
          api_version: @api_version,
          api_resource_name: @api_resource_name,
          id_keyname: @id_keyname,
          banlist: @banlist,
          api_service: DatadogBackup::Client.new
        )
      end

      def all
        @all ||= get_all.map do |resource|
          new(resource[@id_keyname], resource)
        end
        LOGGER.info "Found #{@all.length} #{@api_resource_name}s in Datadog"
        @all
      end

      # Returns a list of all resources in Datadog
      # Do not use directly, but use the child classes' #all method instead
      def get_all
        return @get_all if @get_all

        LOGGER.info("#{myclass}: Fetching all #{@api_resource_name} from Datadog")

        params = {}
        headers = {}
        @get_all = @api_service.get_body("/api/#{@api_version}/#{@api_resource_name}", params, headers)
      end

      # Fetch the specified resource from Datadog and remove the @banlist elements
      def get_by_id(id)
        self.all.find { |resource| resource.id == id }
      end

      def backup_all
        all.map(&:backup)
      end

      def invalidate_cache
        LOGGER.info 'Invalidating cache'
        @get_all = nil
      end

      def myclass
        to_s.split(':').last.downcase
      end
    end
    ##
    # Instance methods

    attr_reader :id, :body, :api_version, :api_resource_name, :id_keyname, :banlist, :api_service

    # If the `id` is nil, then we can only #create from the `body`.
    # If the `id` is not nil, then we can #update or #restore.
    private def initialize(params)
      raise ArgumentError, 'id and body cannot both be nil' if id.nil? && body.nil?

      @id = params[:id]
      @body = params[:body] ? sanitize(params[:body]) : get(@id)

      @api_version = params[:api_version]
      @api_resource_name = params[:api_resource_name]
      @id_keyname = params[:id_keyname]
      @banlist = params[:banlist]
      @api_service = params[:api_service]
    end

    # Fetch the resource from Datadog
    def get
      params = {}
      headers = {}
      body = @api_service.get_body("/api/#{@api_version}/#{@api_resource_name}/#{@id}", params, headers)
      @body = sanitize(body)
    end

    # Returns the diffy diff.
    # Optionally, supply an array of keys to remove from comparison
    def diff
      current = @body.to_yaml
      filesystem = body_from_backup.to_yaml
      result = ::Diffy::Diff.new(current, filesystem, include_plus_and_minus_in_html: true).to_s($options[:diff_format])
      LOGGER.debug("Compared ID #{@id} and found filesystem: #{filesystem} <=> current: #{current} == result: #{result}")
      result.chomp
    end

    def dump
      case $options[:output_format]
      when :json
        JSON.pretty_generate(sanitize(@body))
      when :yaml
        YAML.dump(sanitize(@body))
      else
        raise 'invalid output_format specified or not specified'
      end
    end

    def myclass
      self.class.myclass
    end

    def create(api_resource_name = @api_resource_name)
      headers = {}
      body = @api_service.post_body("/api/#{@api_version}/#{api_resource_name}", @body, headers)
      @id = body[@id_keyname]
      LOGGER.warn "Successfully created #{@id} in datadog."
      self.class.invalidate_cache
      body
    end

    def update(api_resource_name = @api_resource_name)
      headers = {}
      body = @api_service.put_body("/api/#{@api_version}/#{api_resource_name}/#{@id}", @body, headers)
      LOGGER.warn "Successfully restored #{@id} to datadog."
      self.class.invalidate_cache
      body
    end

    def restore
      @body = body_from_backup
      begin
        update
      rescue RuntimeError => e
        raise e.message unless e.message.include?('update failed with error 404')

        create_newly
      ensure
        @body
      end
    end

    private

    # Create a new resource in Datadog, then move the old file to the new resource's ID
    def create_newly
      delete_backup
      create
      backup
    end

    # Returns a hash with @banlist elements removed
    def except(hash)
      outhash = hash.dup
      @banlist.each do |key|
        outhash.delete(key) # delete returns the value at the deleted key, hence the tap wrapper
      end
      outhash
    end

    def sanitize(body)
      except(body.deep_sort)
    end
  end
end
