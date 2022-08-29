# frozen_string_literal: true

require 'diffy'
require 'deepsort'
require 'faraday'
require 'faraday/retry'

module DatadogBackup
  # The default options for backing up and restores.
  # This base class is meant to be extended by specific resources, such as Dashboards, Monitors, and so on.
  class Core
    include ::DatadogBackup::LocalFilesystem
    include ::DatadogBackup::Options

    @retry_options = {
      max: 5,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2
    }

    def api_service
      @api_service ||= Faraday.new(
        url: api_url,
        headers: {
          'DD-API-KEY' => ENV.fetch('DD_API_KEY'),
          'DD-APPLICATION-KEY' => ENV.fetch('DD_APP_KEY')
        }
      ) do |faraday|
        faraday.request :json
        faraday.request :retry, @retry_options
        faraday.response(:logger, LOGGER, { headers: true, bodies: LOGGER.debug?, log_level: :debug }) do |logger|
          logger.filter(/(DD-API-KEY:)([^&]+)/, '\1[REDACTED]')
          logger.filter(/(DD-APPLICATION-KEY:)([^&]+)/, '\1[REDACTED]')
        end
        faraday.response :raise_error
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def api_url
      ENV.fetch('DD_SITE_URL', 'https://api.datadoghq.com/')
    end

    def api_version
      raise 'subclass is expected to implement #api_version'
    end

    def api_resource_name
      raise 'subclass is expected to implement #api_resource_name'
    end

    def backup
      raise 'subclass is expected to implement #backup'
    end

    # Returns the diffy diff.
    # Optionally, supply an array of keys to remove from comparison
    def diff(id)
      current = except(get_by_id(id)).deep_sort.to_yaml
      filesystem = except(load_from_file_by_id(id)).deep_sort.to_yaml
      result = ::Diffy::Diff.new(current, filesystem, include_plus_and_minus_in_html: true).to_s(diff_format)
      LOGGER.debug("Compared ID #{id} and found filesystem: #{filesystem} <=> current: #{current} == result: #{result}")
      result
    end

    # Returns a hash with banlist elements removed
    def except(hash)
      hash.tap do # tap returns self
        @banlist.each do |key|
          hash.delete(key) # delete returns the value at the deleted key, hence the tap wrapper
        end
      end
    end

    def get(id)
      params = {}
      headers = {}
      response = api_service.get("/api/#{api_version}/#{api_resource_name}/#{id}", params, headers)
      body_with_2xx(response)
    end

    def get_all
      return @get_all if @get_all

      params = {}
      headers = {}
      response = api_service.get("/api/#{api_version}/#{api_resource_name}", params, headers)
      @get_all = body_with_2xx(response)
    end

    def get_and_write_file(id)
      write_file(dump(get_by_id(id)), filename(id))
    end

    def get_by_id(id)
      except(get(id))
    end

    def initialize(options)
      @options = options
      @banlist = []
      ::FileUtils.mkdir_p(mydir)
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    # Create a new resource in Datadog
    def create(body)
      headers = {}
      response = api_service.post("/api/#{api_version}/#{api_resource_name}", body, headers)
      body = body_with_2xx(response)
      LOGGER.warn "Successfully created #{body.fetch('id')} in datadog."
      body
    end

    # Update an existing resource in Datadog
    def update(id, body)
      headers = {}
      response = api_service.put("/api/#{api_version}/#{api_resource_name}/#{id}", body, headers)
      body = body_with_2xx(response)
      LOGGER.warn "Successfully restored #{id} to datadog."
      body
    end

    def restore(id)
      body = load_from_file_by_id(id)
      begin
        update(id, body)
      rescue RuntimeError => e
        raise e.message unless e.message.include?('update failed with error 404')

        new_id = create(body).fetch('id')
        FileUtils.rm(find_file_by_id(id))
        get_and_write_file(new_id)
      end
    end

    def body_with_2xx(response)
      unless response.status.to_s =~ /^2/
        raise "#{caller_locations(1,
                                  1)[0].label} failed with error #{response.status}"
      end

      response.body
    end
  end
end
