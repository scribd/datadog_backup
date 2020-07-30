# frozen_string_literal: true

module DatadogBackup
  class Monitors < Core
    def all_monitors
      @all_monitors ||= client_with_200(:get_all_monitors)
    end

    def backup
      all_monitors.map do |monitor|
        id = monitor['id']
        write_file(dump(monitor), filename(id))
      end
    end

    def diff(id)
      banlist = %w[overall_state overall_state_modified]
      super(id, banlist)
    end

    def get_by_id(id)
      all_monitors.select { |monitor| monitor['id'].to_s == id.to_s }.first
    end

    def restore!; end
  end
end