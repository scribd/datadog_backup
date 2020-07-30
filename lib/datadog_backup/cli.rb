# frozen_string_literal: true

require 'optparse'
require 'logger'
require 'amazing_print'

module DatadogBackup
  class Cli
    include ::DatadogBackup::Options

    def any_resource_instance
      resource_instances.first
    end

    def backup
      resource_instances.each(&:backup)
      any_resource_instance.all_files
    end

    def initialize_client
      @options[:client] ||= Dogapi::Client.new(
        datadog_api_key,
        datadog_app_key
      )
    end

    def diffs
      logger.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")

      futures = any_resource_instance
                .all_file_ids_for_selected_resources
                .map do |id|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, id) do |id|
          [id, getdiff(id)]
        end
      end

      ::DatadogBackup::ThreadPool.watcher(logger).join

      Concurrent::Promises
        .zip(*futures)
        .value!
        .to_h
        .reject { |_k, v| v == [] }
    end

    def getdiff(id)
      definitive_resource_instance = matching_resource_instance(any_resource_instance.class_from_id(id))
      definitive_resource_instance.diff(id)
    end

    def initialize(options)
      @options = options
      initialize_client
    end

    def matching_resource_instance(klass)
      resource_instances.select { |resource_instance| resource_instance.class == klass }.first
    end

    def resource_instances
      @resource_instances ||= resources.map do |resource|
        resource.new(@options)
      end
    end

    def run!
      ap(send(action.to_sym), index: false)
    rescue SystemExit, Interrupt
      ::DatadogBackup::ThreadPool.shutdown(logger)
    end
  end
end
