# frozen_string_literal: true

module DatadogBackup
  # SLO specific overrides for backup and restore.
  class SLOs < Resources
    def all
      get_all.fetch('data')
    end

    def backup
      LOGGER.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")
      futures = all.map do |slo|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, slo) do |board|
          id = board[id_keyname]
          get_and_write_file(id)
        end
      end

      watcher = ::DatadogBackup::ThreadPool.watcher
      watcher.join if watcher.status

      Concurrent::Promises.zip(*futures).value!
    end

    def get_by_id(id)
      begin
        slo = except(get(id))
      rescue Faraday::ResourceNotFound => e
        slo = {}
      end
      except(slo)
    end

    def initialize(options)
      super(options)
      @banlist = %w[modified_at url].freeze
    end

    private

    def api_version
      'v1'
    end

    def api_resource_name
      'slo'
    end

    def id_keyname
      'id'
    end
  end
end
