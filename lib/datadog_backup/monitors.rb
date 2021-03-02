# frozen_string_literal: true

module DatadogBackup
  class Monitors < Core
    def all_monitors
      @all_monitors ||= get_all
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
        write_file(dump(get_by_id(id)), filename(id))
      end
    end

    def get_by_id(id)
      monitor = all_monitors.select { |monitor| monitor['id'].to_s == id.to_s }.first
      monitor.nil? ? {} : except(monitor)
    end

    def initialize(options)
      super(options)
      @banlist = %w[overall_state overall_state_modified matching_downtimes modified].freeze
    end
  end
end
