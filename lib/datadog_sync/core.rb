require 'fileutils'
require 'multi_json'

module DatadogSync
  class Core

    def action
      @opts[:action]
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
      self.send(action.to_sym)
    end

    ##
    # subclass is expected to implement #filename
    ##

    def initialize(opts)
      @opts = opts
      output_dirs.map do |dir|
        ::FileUtils.mkdir_p(dir)
      end
    end

    def jsondump(object)
      ::MultiJson.dump(object, pretty: true)
    end

    def logger
      @opts[:logger]
    end


    def output_dir
      @opts[:output_dir]

    end

    def output_dirs
      %w[ dashboards monitors ].map do |subdir|
        File.join(output_dir, subdir)
      end
    end

    def restore
      self.restore!
    end

    ##
    # subclass is expected to implement #restore!
    ##

    def write(data, filename)
      logger.info "Backing up #{filename}"
      file = ::File.open(filename,'w')
      file.write(data)
    ensure
      file.close
    end

  end
end
