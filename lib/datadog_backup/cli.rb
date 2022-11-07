# frozen_string_literal: true

require 'optparse'
require 'amazing_print'

module DatadogBackup
  # CLI is the command line interface for the datadog_backup gem.
  class Cli
    def initialize(options)
      $options = options
    end

    def backup
      $options[:resources].each(&:purge)
      $options[:resources].each(&:backup_all)
      any_resource_instance.all_files
    end

    def diffs
      $options[:resources].each do |resource|
        resource.all.each do |resource_instance|
          next if resource_instance.diff.nil? || resource_instance.diff.empty?

          puts resource_instance.diff
        end
      end
    end

    def restore
      $options[:resources].each do |resource|
        resource.all.each do |resource_instance|
          next if resource_instance.diff.nil? || resource_instance.diff.empty?

          if $options[:force_restore]
            resource_instance.restore
          else
            ask_to_restore(resource_instance)
          end
        end
      end
    end

    def run!
      case $options[:action]
      when 'backup'
        LOGGER.info('Starting backup.')
        backup
      when 'restore'
        LOGGER.info('Starting restore.')
        restore
      when 'diffs'
        LOGGER.info('Starting diffs.')
        diffs
      else
        fatal 'No action specified.'
      end
      LOGGER.info('Done.')
    rescue SystemExit, Interrupt
      ::DatadogBackup::ThreadPool.shutdown
    end

    private

    ##
    # Interact with the user

    def ask_to_restore(resource_instance)
      puts '--------------------------------------------------------------------------------'
      puts resource_instance.diff
      puts '(r)estore to Datadog, overwrite local changes and (d)ownload, (s)kip, or (q)uit?'
      loop do
        response = $stdin.gets.chomp
        case response
        when 'q'
          exit
        when 'r'
          puts "Restoring #{resource_instance.id} to Datadog."
          resource_instance.restore
          break
        when 'd'
          puts "Downloading #{resource_instance.id} from Datadog."
          resource_instance.backup
          break
        when 's'
          break
        else
          puts 'Invalid response, please try again.'
        end
      end
    end

    ##
    # Finding the right resource instance to use.
    def any_resource_instance
      $options[:resources].first
    end
  end
end
