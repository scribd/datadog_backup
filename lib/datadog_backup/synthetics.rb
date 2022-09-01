# frozen_string_literal: true

module DatadogBackup
  # Synthetic specific overrides for backup and restore.
  class Synthetics < Resources
    @api_version = 'v1'
    @api_resource_name = 'synthetics/tests' # used for list, but #instance_resource_name is used for get, create, update
    @id_keyname = 'public_id'
    @banlist = %w[creator created_at modified_at monitor_id public_id].freeze
    @api_service = DatadogBackup::Client.new

    class<<self
      def get_all
        raw = super
        raw.fetch('tests')
      end
    end

    def instance_resource_name
      return 'synthetics/tests/browser' if @body.fetch('type') == 'browser'
      return 'synthetics/tests/api' if @body.fetch('type') == 'api'
    end
    
    def get
      super(api_resource_name: instance_resource_name)
    end

    def create
      super(api_resource_name: instance_resource_name)
    end

    def update
      super(api_resource_name: instance_resource_name)
    end
  end
end
