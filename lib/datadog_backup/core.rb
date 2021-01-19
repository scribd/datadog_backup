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

    # Returns the diffy diff.
    # Optionally, supply an array of keys to remove from comparison
    def diff(id)
      current = except(get_by_id(id)).deep_sort.to_yaml
      filesystem = except(load_from_file_by_id(id)).deep_sort.to_yaml
      result = ::Diffy::Diff.new(current, filesystem, include_plus_and_minus_in_html: true).to_s(diff_format)
      logger.debug("Compared ID #{id} and found #{result}")
      result
    end

    # Returns a hash with banlist elements removed
    def except(hash)
      hash.tap do # tap returns self
        @banlist.each do |key|
          hash.delete(key) # delete returns the value at the deleted key, hence the tap wrapper
        end
      end
    end

    def get(id)
      with_200 do
        api_service.request(Net::HTTP::Get, "/api/#{api_version}/#{api_resource_name}/#{id}", nil, nil, false)
      end
    end

    def get_all
      with_200 do
        api_service.request(Net::HTTP::Get, "/api/#{api_version}/#{api_resource_name}", nil, nil, false)
      end
    end

    def get_and_write_file(id)
      write_file(dump(get_by_id(id)), filename(id))
    end

    def get_by_id(id)
      except(get(id))
    end

    def initialize(options)
      @options = options
      @banlist = []
      ::FileUtils.mkdir_p(mydir)
    end

    def myclass
      self.class.to_s.split(':').last.downcase
    end

    # Calls out to Datadog and checks for a '200' response
    def create(body)
      result = with_200 do
        api_service.request(Net::HTTP::Post, "/api/#{api_version}/#{api_resource_name}", nil, body, true)
      end
      logger.warn 'Successfully created in datadog.'
      result
    end

    # Calls out to Datadog and checks for a '200' response
    def update(id, body)
      result = with_200 do
        api_service.request(Net::HTTP::Put, "/api/#{api_version}/#{api_resource_name}/#{id}", nil, body, true)
      end
      logger.warn 'Successfully restored to datadog.'
      result
    end

    def restore(id)
      body = load_from_file_by_id(id)
      begin
        update(id, body)
      rescue RuntimeError => e
        if e.message.include?('Request failed with error ["404"')
          new_id = create(body).fetch('id')

          FileUtils.rm(find_file_by_id(id))
          get_and_write_file(new_id)
        else
          raise e.message
        end
      end
    end

    def with_200
      max_retries = 6
      retries ||= 0

      response = yield
      raise "Request failed with error #{response}" unless response[0] == '200'

      response[1]
    rescue ::Net::OpenTimeout => e
      if (retries += 1) <= max_retries
        sleep(0.1 * retries**5) # 0.1, 3.2, 24.3, 102.4 seconds per retry
        retry
      else
        raise "Net::OpenTimeout: #{e.message}"
      end
    end
  end
end
