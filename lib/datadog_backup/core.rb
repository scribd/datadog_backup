require 'hashdiff'

module DatadogBackup
  class Core
    include ::DatadogBackup::LocalFilesystem
    include ::DatadogBackup::Options

    def backup
      raise 'subclass is expected to implement #backup'
    end

    def client_with_200(method, *id)
      response = client.send(method, *id)
      logger.debug response
      if response[0] == '200'
      else
        raise "Method #{method} failed with error #{response}"
      end
      response[1]
    rescue ::Net::OpenTimeout
      sleep(0.1)
      retry
    end

    def diff(id)
      current = get_by_id(id)
      filesystem = load_from_file_by_id(id)
      Hashdiff.diff(current, filesystem)
    end

    def get_by_id(id)
      raise 'subclass is expected to implement #get_by_id(id)'
    end

    def initialize(options)
      @options = options
      ::FileUtils.mkdir_p(mydir)
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    def restore
      raise 'subclass is expected to implement #restore'
    end

  end
end
