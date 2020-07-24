require 'fileutils'
require 'concurrent-ruby'
require 'json'
require 'yaml'
require 'hashdiff'
require 'awesome_print'

module DatadogBackup
  class Core
    include ::DatadogBackup::LocalFilesystem

    def action
      @opts[:action]
    end

    def backup
      raise 'subclass is expected to implement #backup'
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

    def diff(id)
      current = class_from_id(id).public_send(:get_by_id, id)
      filesystem = load_from_file_by_id(id)
      Hashdiff.diff(current, filesystem)
    end

    def diffs
      result = all_ids.map {|id| [id, diff(id)] }.to_h
      ap(result, index: false)
      result
    end

    def execute!
      futures = send(action.to_sym)
      logger.debug(futures.map(&:value!))
    end

    def get_by_id(id)
      raise 'subclass is expected to implement #get_by_id(id)'
    end

    def initialize(opts)
      @opts = opts
      ::FileUtils.mkdir_p(mydir)
    end

    def logger
      @opts[:logger]
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    def restore
      raise 'subclass is expected to implement #restore'
    end

  end
end
