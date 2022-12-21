# frozen_string_literal: true

module DatadogBackup
  class Resources
    module ClassMethods
      def new_resource(id: nil, body: nil)
        raise ArgumentError, 'id and body cannot both be nil' if id.nil? && body.nil?

        new(
          id: id,
          body: body,
          api_version: @api_version,
          api_resource_name: @api_resource_name,
          id_keyname: @id_keyname,
          banlist: @banlist,
          api_service: @api_service
        )
      end

      def all
        @all ||= get_all.map do |resource|
          new_resource(id: resource.fetch(@id_keyname), body: resource)
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
        body = @api_service.get_body("/api/#{@api_version}/#{@api_resource_name}", params, headers)
        @get_all = @dig_in_list_body ? body.fetch(*@dig_in_list_body) : body
      end

      # Fetch the specified resource from Datadog and remove the @banlist elements
      def get_by_id(id)
        all.find { |resource| resource.id == id }
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
  end
end
