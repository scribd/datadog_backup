module DatadogBackup
  module Options
    def action
      @options[:action]
    end

    def backup_dir
      @options[:backup_dir]
    end
    
    def client
      @options[:client]
    end

    def datadog_api_key
      @options[:datadog_api_key]
    end

    def datadog_app_key
      @options[:datadog_app_key]
    end

    def logger
      @options[:logger]
    end
    
    # Either :json or :yaml
    def output_format
      @options[:output_format]
    end

    def resources
      @options[:resources]
    end
  end
end