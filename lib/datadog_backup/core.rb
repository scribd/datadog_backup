# frozen_string_literal: true

require 'diffy'
require 'deepsort'

module DatadogBackup
  class Core
    include ::DatadogBackup::LocalFilesystem
    include ::DatadogBackup::Options

    def api_service
      raise 'subclass is expected to implement #api_service'
    end

    def api_version
      raise 'subclass is expected to implement #api_version'
    end

    def api_resource_name
      raise 'subclass is expected to implement #api_resource_name'
    end

    def backup
      raise 'subclass is expected to implement #backup'
    end

    # Calls out to Datadog and checks for a '200' response
    def client_with_200(method, *id)
      max_retries = 6
      retries ||= 0

      response = client.send(method, *id)

      # logger.debug response
      raise "Method #{method} failed with error #{response}" unless response[0] == '200'

      response[1]
    rescue ::Net::OpenTimeout => e
      if (retries += 1) <= max_retries
        sleep(0.1 * retries**5) # 0.1, 3.2, 24.3, 102.4 seconds per retry
        retry
      else
        raise "Method #{method} failed with error #{e.message}"
      end
    end

    # Returns the diffy diff.
    # Optionally, supply an array of keys to remove from comparison
    def diff(id, banlist = [])
      current = except(get_by_id(id), banlist).deep_sort.to_yaml
      filesystem = except(load_from_file_by_id(id), banlist).deep_sort.to_yaml
      result = ::Diffy::Diff.new(current, filesystem, include_plus_and_minus_in_html: true).to_s(diff_format)
      logger.debug("Compared ID #{id} and found #{result}")
      result
    end

    # Returns a hash with banlist elements removed
    def except(hash, banlist)
      hash.tap do # tap returns self
        banlist.each do |key|
          hash.delete(key) # delete returns the value at the deleted key, hence the tap wrapper
        end
      end
    end

    def get_and_write_file(id)
      write_file(dump(get_by_id(id)), filename(id))
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

    def update(id, body)
      api_service.request(Net::HTTP::Put, "/api/#{api_version}/#{api_resource_name}/#{id}", nil, body, true)
    end

    # Calls out to Datadog and checks for a '200' response
    def update_with_200(id, body)
      max_retries = 6
      retries ||= 0

      response = update(id, body)

      # logger.debug response
      raise "Update failed with error #{response}" unless response[0] == '200'

      logger.warn "Successfully restored #{id} to datadog."

      response[1]
    rescue ::Net::OpenTimeout => e
      if (retries += 1) <= max_retries
        sleep(0.1 * retries**5) # 0.1, 3.2, 24.3, 102.4 seconds per retry
        retry
      else
        raise "Update failed with error #{e.message}"
      end
    end
  end
end
