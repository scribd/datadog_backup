# frozen_string_literal: true

require 'optparse'
require 'amazing_print'

module DatadogBackup
  # CLI is the command line interface for the datadog_backup gem.
  class Cli
    include ::DatadogBackup::Options

    def all_diff_futures
      LOGGER.info("Starting diffs on #{::DatadogBackup::ThreadPool::TPOOL.max_length} threads")
      any_resource_instance
        .all_file_ids_for_selected_resources
        .map do |file_id|
        Concurrent::Promises.future_on(::DatadogBackup::ThreadPool::TPOOL, file_id) do |fid|
          [fid, getdiff(fid)]
        end
      end
    end

    def any_resource_instance
      resource_instances.first
    end

    def backup
      resource_instances.each(&:purge)
      resource_instances.each(&:backup)
      any_resource_instance.all_files
    end

    def definitive_resource_instance(id)
      matching_resource_instance(any_resource_instance.class_from_id(id))
    end

    def diffs
      futures = all_diff_futures
      ::DatadogBackup::ThreadPool.watcher.join

      format_diff_output(
        Concurrent::Promises
          .zip(*futures)
          .value!
          .compact
      )
    end

    def getdiff(id)
      result = definitive_resource_instance(id).diff(id)
      case result
      when ''
        nil
      when "\n"
        nil
      when '<div class="diff"></div>'
        nil
      else
        result
      end
    end

    # rubocop:disable Style/StringConcatenation
    def format_diff_output(diff_output)
      case diff_format
      when nil, :color
        diff_output.map do |id, diff|
          " ---\n id: #{id}\n#{diff}"
        end.join("\n")
      when :html
        '<html><head><style>' +
          Diffy::CSS +
          '</style></head><body>' +
          diff_output.map do |id, diff|
            "<br><br> ---<br><strong> id: #{id}</strong><br>" + diff
          end.join('<br>') +
          '</body></html>'
      else
        raise 'Unexpected diff_format.'
      end
    end
    # rubocop:enable Style/StringConcatenation

    def initialize(options)
      @options = options
    end

    def restore
      futures = all_diff_futures
      watcher = ::DatadogBackup::ThreadPool.watcher

      futures.each do |future|
        id, diff = *future.value!
        next unless diff

        if @options[:force_restore]
          definitive_resource_instance(id).restore(id)
        else
          ask_to_restore(id, diff)
        end
      end
      watcher.join if watcher.status
    end

    def run!
      puts(send(action.to_sym))
    rescue SystemExit, Interrupt
      ::DatadogBackup::ThreadPool.shutdown
    end

    private

    def ask_to_restore(id, diff)
      puts '--------------------------------------------------------------------------------'
      puts format_diff_output([id, diff])
      puts '(r)estore to Datadog, overwrite local changes and (d)ownload, (s)kip, or (q)uit?'
      loop do
        response = $stdin.gets.chomp
        case response
        when 'q'
          exit
        when 'r'
          puts "Restoring #{id} to Datadog."
          definitive_resource_instance(id).restore(id)
          break
        when 'd'
          puts "Downloading #{id} from Datadog."
          definitive_resource_instance(id).get_and_write_file(id)
          break
        when 's'
          break
        else
          puts 'Invalid response, please try again.'
        end
      end
    end

    def matching_resource_instance(klass)
      resource_instances.select { |resource_instance| resource_instance.instance_of?(klass) }.first
    end

    def resource_instances
      @resource_instances ||= resources.map do |resource|
        resource.new(@options)
      end
    end
  end
end
