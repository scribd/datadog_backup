# frozen_string_literal: true

module DatadogBackup
  # Monitor specific overrides for backup and restore.
  class Monitors < Core
    def all
      get_all
    end

    def backup
      all.map do |monitor|
        id = monitor['id']
        write_file(dump(get_by_id(id)), filename(id))
      end
    end

    def get_by_id(id)
      monitor = all.select { |m| m['id'].to_s == id.to_s }.first
      monitor.nil? ? {} : except(monitor)
    end

    def initialize(options)
      super(options)
      @banlist = %w[overall_state overall_state_modified matching_downtimes modified].freeze
    end

    private

    def api_version
      'v1'
    end

    def api_resource_name
      'monitor'
    end
  end
end
