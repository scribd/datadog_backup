module DatadogBackup
  module ThreadPool
    TPOOL = ::Concurrent::ThreadPoolExecutor.new(
      min_threads: [2, Concurrent.processor_count].max,
      max_threads: [2, Concurrent.processor_count].max * 2,
      max_queue: [2, Concurrent.processor_count].max * 512,
      fallback_policy: :abort
    )
    def self.watcher(logger)
      Thread.new(TPOOL) do |pool|
        while(pool.queue_length > 0) do
          sleep 2
          logger.info("#{pool.queue_length} tasks remaining for execution.")
        end
      end
    end
  end
end
