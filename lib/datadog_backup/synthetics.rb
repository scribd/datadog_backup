# frozen_string_literal: true

module DatadogBackup
  # Synthetic specific overrides for backup and restore.
  class Synthetics < Resources
    @@api_version = 'v1'
    @@api_resource_name = 'synthetics/tests'
    @@id_keyname = 'public_id'
    @@banlist = %w[creator created_at modified_at monitor_id public_id].freeze
    @@api_service = DatadogBackup::Client.new

    def self.get_all
      raw = super
      raw.fetch('tests')
    end

    def instance_resource_name
      return 'synthetics/tests/browser' if @body.fetch('type') == 'browser'
      return 'synthetics/tests/api' if @body.fetch('type') == 'api'
    end

    def create
      super(instance_resource_name)
    end

    def update
      super(instance_resource_name)
    end
  end
end
