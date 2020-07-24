module DatadogBackup
  class Monitors < Core
    def all_monitors
      client_with_200(:get_all_monitors)
    end

    def backup!
      all_monitors.map do |monitor|
        Concurrent::Future.execute do
          id = monitor['id']
          write(dump(monitor), filename(id))
        end
      end
    end

    def restore!; end
  end
end
