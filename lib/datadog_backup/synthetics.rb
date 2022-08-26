# frozen_string_literal: true

module DatadogBackup
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
        $stderr.puts JSON.parse(dump(get_by_id(id)))
        write_file(dump(get_by_id(id)), filename(id))
      end
    end

    def get_by_id(id)
      synthetic = all.select { |synthetic| synthetic['public_id'].to_s == id.to_s }.first
      synthetic.nil? ? {} : except(synthetic)
    end

    def initialize(options)
      super(options)
      @banlist = %w[created_at modified_at].freeze
    end
  end
end
