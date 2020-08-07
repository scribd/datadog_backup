# frozen_string_literal: true

module DatadogBackup
  class Dashboards < Core
    BANLIST = %w[modified_at url]

    def all_boards
      client_with_200(:get_all_boards).fetch('dashboards')
    end

    def api_service
      # The underlying class from Dogapi that talks to datadog
      client.instance_variable_get(:@dashboard_service)
    end

    def api_version
      'v1'
    end

    def api_resource_name
      'dashboard'
    end

    def backup
      logger.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")

      futures = all_boards.map do |board|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, board) do |board|
          id = board['id']
          get_and_write_file(id)
        end
      end

      watcher = ::DatadogBackup::ThreadPool.watcher(logger)
      watcher.join if watcher.status

      Concurrent::Promises.zip(*futures).value!
    end

    def diff(id)
      super(id, BANLIST)
    end

    def get_by_id(id)
      except(client_with_200(:get_board, id), BANLIST)
    end

    def restore!; end
  end
end
