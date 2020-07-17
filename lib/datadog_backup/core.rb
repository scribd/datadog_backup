require 'fileutils'
require 'multi_json'
require 'concurrent-ruby'

module DatadogBackup
  class Core

    def action
      @opts[:action]
    end

    def backup
      backup!
    end

    ##
    # subclass is expected to implement #backup!
    ##

    def client
      @opts[:client]
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

    def execute!
      futures = send(action.to_sym)
      logger.info(futures.map(&:value!))
    end

    def filename(id)
      ::File.join(mydir, "#{id}.json")
    end


    def initialize(opts)
      @opts = opts
      ::FileUtils.mkdir_p(mydir)
    end

    def jsondump(object)
      ::MultiJson.dump(object, pretty: true)
    end

    def logger
      @opts[:logger]
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    def mydir
      ::File.join(output_dir,myclass)
    end

    def output_dir
      @opts[:output_dir]
    end

    def restore
      restore!
    end

    ##
    # subclass is expected to implement #restore!
    ##

    def write(data, filename)
      logger.info "Backing up #{filename}"
      file = ::File.open(filename, 'w')
      file.write(data)
    ensure
      file.close
    end
  end
end
