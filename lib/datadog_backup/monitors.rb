# frozen_string_literal: true

module DatadogBackup
  # Monitor specific overrides for backup and restore.
  class Monitors < Resources
      class<<self
        @api_version = 'v1'
        @api_resource_name = 'monitor'
        @id_keyname = 'id'
        @banlist = %w[overall_state overall_state_modified matching_downtimes modified].freeze
      end


  end
end
