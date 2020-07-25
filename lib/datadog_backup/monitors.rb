module DatadogBackup
  class Monitors < Core
    def all_monitors
      @all_monitors ||= client_with_200(:get_all_monitors)
    end

    def backup
      all_monitors.map do |monitor|
        Concurrent::Future.execute do
          id = monitor['id']
          write_file(dump(monitor), filename(id))
        end
      end
    end

    def get_by_id(id)
      all_monitors.select {|monitor| monitor['id'] == id }.first
    end

    def restore!; end
  end
end
