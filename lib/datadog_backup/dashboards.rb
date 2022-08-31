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
  end
end
