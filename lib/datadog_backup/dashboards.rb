# frozen_string_literal: true

module DatadogBackup
  class Dashboards < Core

    def all_dashboards
      get_all.fetch('dashboards')
    end

    def api_version
      'v1'
    end

    def api_resource_name
      'dashboard'
    end

    def backup
      LOGGER.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")

      futures = all_dashboards.map do |board|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, board) do |board|
          id = board['id']
          get_and_write_file(id)
        end
      end

      watcher = ::DatadogBackup::ThreadPool.watcher
      watcher.join if watcher.status

      Concurrent::Promises.zip(*futures).value!
    end

    def initialize(options)
      super(options)
      @banlist = %w[modified_at url].freeze
    end
  end
end
