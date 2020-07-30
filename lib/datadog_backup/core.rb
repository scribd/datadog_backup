# frozen_string_literal: true

require 'hashdiff'

module DatadogBackup
  class Core
    include ::DatadogBackup::LocalFilesystem
    include ::DatadogBackup::Options

    def backup
      raise 'subclass is expected to implement #backup'
    end

    # Calls out to Datadog and checks for a '200' response
    def client_with_200(method, *id)
      max_retries = 6
      retries ||= 0
      response = client.send(method, *id)
      logger.debug response
      if response[0] == '200'
      else
        raise "Method #{method} failed with error #{response}"
      end
      response[1]
    rescue ::Net::OpenTimeout => e
      if (retries += 1) <= max_retries
        sleep(0.1 * retries**5) # 0.1, 3.2, 24.3, 102.4 seconds per retry
        retry
      else
        raise "Method #{method} failed with error #{e.message}"
      end
    end

    # Returns the Hashdiff diff.
    # Optionally, supply an array of keys to remove from comparison
    def diff(id, banlist = [])
      current = except(get_by_id(id), banlist)
      filesystem = except(load_from_file_by_id(id), banlist)
      result = Hashdiff.diff(current, filesystem)
      logger.debug("Compared ID #{id} and found #{result}")
      result
    end

    # Returns a hash with banlist elements removed
    def except(hash, banlist)
      hash.tap do |hash| # tap returns self
        banlist.each do |key|
          hash.delete(key) # delete returns the value at the deleted key, hence the tap wrapper
        end
      end
    end

    def get_by_id(_id)
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
