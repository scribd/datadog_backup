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

    def execute!
      logger.warn "Hello World: #{@opts}"
    end

    def initialize(opts)
      @opts = opts
    end

    def logger
      @opts[:logger]
    end

    def marshall(data, filename)
      File.open(filename,'w') do |f|
        f.write Marshal.dump(data)
      end
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

    def client_with_200(method, *id)
      response = client.send(method, *id)
      if response[0] == '200'
      else
        raise "Method #{method} failed with error #{response}"
      end
      response[1]
    end

  end
end
