require 'fileutils'
require 'concurrent-ruby'
require 'json'
require 'yaml'

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

    def backup_dir
      @opts[:backup_dir]
    end

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
      logger.debug(futures.map(&:value!))
    end

    def filename(id)
      ::File.join(mydir, "#{id}.#{output_format.to_s}")
    end


    def initialize(opts)
      @opts = opts
      ::FileUtils.mkdir_p(mydir)
    end

    def dump(object)
      if output_format == :json
        JSON.pretty_generate(object)
      elsif output_format == :yaml
        YAML.dump(object)
      else
        raise "output_format not specified"
      end
    end

    def load(string)
      if output_format == :json
        JSON.load(string)
      elsif output_format == :yaml
        YAML.load(string)
      else
        raise "output_format not specified"
      end
    end

    def logger
      @opts[:logger]
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    def mydir
      ::File.join(backup_dir,myclass)
    end

    # Either :json or :yaml
    def output_format
      @opts[:output_format]
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
