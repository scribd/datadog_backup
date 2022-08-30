# frozen_string_literal: true

module DatadogBackup
  # Synthetic specific overrides for backup and restore.
  class Synthetics < Core
    def all
      get_all.fetch('tests')
    end

    def backup
      all.map do |synthetic|
        id = synthetic[id_keyname]
        get_and_write_file(id)
      end
    end

    def get_by_id(id)
      synthetic = all.select { |s| s[id_keyname].to_s == id.to_s }.first
      synthetic.nil? ? {} : except(synthetic)
    end

    def initialize(options)
      super(options)
      @banlist = %w[creator created_at modified_at monitor_id public_id].freeze
    end

    def create(body)
      create_api_resource_name = api_resource_name(body)
      headers = {}
      response = api_service.post("/api/#{api_version}/#{create_api_resource_name}", body, headers)
      resbody = body_with_2xx(response)
      LOGGER.warn "Successfully created #{resbody.fetch(id_keyname)} in datadog."
      LOGGER.info 'Invalidating cache'
      @get_all = nil
      resbody
    end

    def update(id, body)
      update_api_resource_name = api_resource_name(body)
      headers = {}
      response = api_service.put("/api/#{api_version}/#{update_api_resource_name}/#{id}", body, headers)
      resbody = body_with_2xx(response)
      LOGGER.warn "Successfully restored #{id} to datadog."
      LOGGER.info 'Invalidating cache'
      @get_all = nil
      resbody
    end

    private

    def api_version
      'v1'
    end

    def api_resource_name(body = nil)
      return 'synthetics/tests' if body.nil?
      return 'synthetics/tests' if body['type'].nil?
      return 'synthetics/tests/browser' if body['type'].to_s == 'browser'
      return 'synthetics/tests/api' if body['type'].to_s == 'api'

      raise "Unknown type #{body['type']}"
    end

    def id_keyname
      'public_id'
    end
  end
end
