# frozen_string_literal: true

module DatadogBackup
  # Dashboards specific overrides for backup and restore.
  class Dashboards < Resources
    class<<self
      @api_version = 'v1'
      @api_resource_name = 'dashboard'
      @id_keyname = 'id'
      @banlist = %w[modified_at url].freeze

      def self.all
        LOGGER.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")
        return @all if @all

        futures = get_all.map do |resource|
          Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, resource) do |dashboard|
            d = new(dashboard[@id_keyname])
            d.get
            d
          end
        end

        watcher = ::DatadogBackup::ThreadPool.watcher
        watcher.join if watcher.status
        @all = Concurrent::Promises.zip(*futures).value!
      end

      def self.get_all
        raw = super
        warn raw
        raw.fetch('dashboards')
      end
    end

  end
end
