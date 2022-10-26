# frozen_string_literal: true

module DatadogBackup
  # Dashboards specific overrides for backup and restore.
  class Dashboards < Resources
    @api_version = 'v1'
    @api_resource_name = 'dashboard'
    @id_keyname = 'id'
    @banlist = %w[modified_at url].freeze
    @api_service = DatadogBackup::Client.new
    @dig_in_list_body = 'dashboards'

    def self.all
      @all ||= get_all.map do |resource|
        new_resource(id: resource.fetch(@id_keyname))
      end
      LOGGER.info "Found #{@all.length} #{@api_resource_name}s in Datadog"
      @all
    end
  end
end
