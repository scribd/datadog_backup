module DatadogBackup
  class Dashboards < Core
    def all_boards
      client_with_200(:get_all_boards).fetch('dashboards')
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

      return Concurrent::Promises.zip(*futures).value!
      watcher.join
    end

    def get_and_write_file(id)
      write_file(dump(get_by_id(id)), filename(id))
    end

    def get_by_id(id)
      client_with_200(:get_board, id)
    end

    def restore!; end
  end
end
