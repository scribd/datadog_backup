# frozen_string_literal: true

module DatadogBackup
  # Describes what the user wants to see done.
  module Options
    def action
      @options[:action]
    end

    def backup_dir
      @options[:backup_dir]
    end

    def concurrency_limit
      @options[:concurrency_limit] | 2
    end

    def diff_format
      @options[:diff_format]
    end

    # Either :json or :yaml
    def output_format
      @options[:output_format]
    end

    def resources
      @options[:resources]
    end

    def force_restore
      @options[:force_restore]
    end
  end
end
