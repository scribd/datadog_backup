# frozen_string_literal: true

module DatadogBackup
  # Monitor specific overrides for backup and restore.
  class Monitors < Resources
    @api_version = 'v1'
    @api_resource_name = 'monitor'
    @id_keyname = 'id'
    @banlist = %w[id matching_downtimes modified overall_state overall_state_modified].freeze
    @api_service = DatadogBackup::Client.new
    @dig_in_list_body = nil
  end
end
