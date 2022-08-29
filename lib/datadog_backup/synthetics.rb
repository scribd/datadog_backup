# frozen_string_literal: true

module DatadogBackup
  # Synthetic specific overrides for backup and restore.
  class Synthetics < Core
    def all
      get_all.fetch('tests')
    end

    def api_version
      'v1'
    end

    def api_resource_name
      'synthetics/tests'
    end

    def backup
      all.map do |synthetic|
        id = synthetic['public_id']
        write_file(dump(get_by_id(id)), filename(id))
      end
    end

    def get_by_id(id)
      synthetic = all.select { |s| s['public_id'].to_s == id.to_s }.first
      synthetic.nil? ? {} : except(synthetic)
    end

    def initialize(options)
      super(options)
      @banlist = %w[created_at modified_at].freeze
    end

    def create(body)
      create_api_resource_name = api_or_browser(body)
      headers = {}
      response = api_service.post("/api/#{api_version}/#{create_api_resource_name}", body, headers)
      resbody = body_with_2xx(response)
      LOGGER.warn "Successfully created #{resbody.fetch('public_id')} in datadog."
      resbody
    end

    def update(id, body)
      update_api_resource_name = api_or_browser(body)
      headers = {}
      response = api_service.put("/api/#{api_version}/#{update_api_resource_name}/#{id}", body, headers)
      resbody = body_with_2xx(response)
      LOGGER.warn "Successfully restored #{id} to datadog."
      resbody
    end

    private

    def api_or_browser(body)
      if body['type'] == 'browser'
        'synthetics/tests/browser'
      else
        'synthetics/tests/api'
      end
    end
  end
end
