# frozen_string_literal: true

module DatadogBackup
  # Dashboards specific overrides for backup and restore.
  class Dashboards < Resources
    @api_version = 'v1'
    @api_resource_name = 'dashboard'
    @id_keyname = 'id'
    @banlist = %w[modified_at url].freeze
    @api_service = DatadogBackup::Client.new
    @dig_in_list_body = 'dashboards'

    def self.all
      return @all if @all

      futures = get_all.map do |resource|
        Concurrent::Promises.future_on(DatadogBackup::ThreadPool::TPOOL, resource) do |r|
          new_resource(id: r.fetch(@id_keyname))
        end
      end
      LOGGER.info "Found #{futures.length} #{@api_resource_name}s in Datadog"

      watcher = DatadogBackup::ThreadPool.watcher
      watcher.join if watcher.status
      @all = Concurrent::Promises.zip(*futures).value!
    end
  end
end
