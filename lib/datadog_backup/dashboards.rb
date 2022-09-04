# frozen_string_literal: true

module DatadogBackup
  # Dashboards specific overrides for backup and restore.
  class Dashboards < Resources
    @api_version = 'v1'
    @api_resource_name = 'dashboard'
    @id_keyname = 'id'
    @banlist = %w[modified_at url].freeze
    @api_service = DatadogBackup::Client.new

    class << self
      def all
        return @all if @all

        LOGGER.info("Fetching dashboards on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")
        futures = get_all.map do |resource|
          Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, resource) do |dashboard|
            d = new_resource(id: dashboard.fetch(@id_keyname))
            d.get
            d
          end
        end

        watcher = ::DatadogBackup::ThreadPool.watcher
        watcher.join if watcher.status
        @all = Concurrent::Promises.zip(*futures).value!
      end

      def get_all
        raw = super
        raw.fetch('dashboards')
      end
    end
  end
end
