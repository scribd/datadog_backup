# frozen_string_literal: true

module DatadogBackup
  class Monitors < Core
    API_SERVICE_NAME = :@monitor_svc
    def all_monitors
      @all_monitors ||= client_with_200(:get_all_monitors)
    end

    def api_service
      # The underlying class from Dogapi that talks to datadog
      client.instance_variable_get(:@monitor_svc)
    end

    def api_version
      'v1'
    end

    def api_resource_name
      'monitor'
    end

    def backup
      all_monitors.map do |monitor|
        id = monitor['id']
        write_file(dump(monitor), filename(id))
      end
    end

    def diff(id)
      banlist = %w[overall_state overall_state_modified matching_downtimes modified]
      super(id, banlist)
    end

    def get_by_id(id)
      all_monitors.select { |monitor| monitor['id'].to_s == id.to_s }.first
    end

    def restore!; end
  end
end
