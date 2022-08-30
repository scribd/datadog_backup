# frozen_string_literal: true

module DatadogBackup
  # Dashboards specific overrides for backup and restore.
  class Dashboards < Resources
    def all
      get_all.fetch('dashboards')
    end

    def backup
      LOGGER.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")
      futures = all.map do |dashboard|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, dashboard) do |board|
          id = board[id_keyname]
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

    private

    def api_version
      'v1'
    end

    def api_resource_name
      'dashboard'
    end

    def id_keyname
      'id'
    end
  end
end
