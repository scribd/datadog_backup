require 'fileutils'
require 'multi_json'

module DatadogSync
  class Core

    def action
      @opts[:action]
    end

    def action!
      self.send(action.to_sym)
    end

    def backup
      self.backup!
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
    end

    def execute!
      action!
    end

    ##
    # subclass is expected to implement #filename
    ##

    def initialize(opts)
      @opts = opts
      ::FileUtils.mkdir_p(output_dir)
    end

    def jsondump(object)
      ::MultiJson.dump(object, pretty: true)
    end

    def logger
      @opts[:logger]
    end

    def write(data, filename)
      logger.info "Backing up #{filename}"
      file = ::File.open(filename,'w')
      file.write(data)
    ensure
      file.close
    end

    def output_dir
      @opts[:output_dir]
    end


    def restore
      self.restore!
    end

    ##
    # subclass is expected to implement #restore!
    ##
    #

  end
end
