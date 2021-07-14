# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'
require 'deepsort'

module DatadogBackup
  module LocalFilesystem
    ##
    # Meant to be mixed into DatadogBackup::Core
    # Relies on @options[:backup_dir] and @options[:output_format]

    def all_files
      ::Dir.glob(::File.join(backup_dir, '**', '*')).select { |f| ::File.file?(f) }
    end

    def all_file_ids
      all_files.map { |file| ::File.basename(file, '.*') }
    end

    def all_file_ids_for_selected_resources
      all_file_ids.select do |id|
        resources.include? class_from_id(id)
      end
    end

    def class_from_id(id)
      class_string = ::File.dirname(find_file_by_id(id)).split('/').last.capitalize
      ::DatadogBackup.const_get(class_string)
    end

    def dump(object)
      case output_format
      when :json
        JSON.pretty_generate(object.deep_sort)
      when :yaml
        YAML.dump(object.deep_sort)
      else
        raise 'invalid output_format specified or not specified'
      end
    end

    def filename(id)
      ::File.join(mydir, "#{id}.#{output_format}")
    end

    def file_type(filepath)
      ::File.extname(filepath).strip.downcase[1..-1].to_sym
    end

    def find_file_by_id(id)
      ::Dir.glob(::File.join(backup_dir, '**', "#{id}.*")).first
    end

    def load_from_file(string, output_format)
      case output_format
      when :json
        JSON.parse(string)
      when :yaml
        YAML.safe_load(string)
      else
        raise 'invalid output_format specified or not specified'
      end
    end

    def load_from_file_by_id(id)
      filepath = find_file_by_id(id)
      load_from_file(::File.read(filepath), file_type(filepath))
    end

    def mydir
      ::File.join(backup_dir, myclass)
    end

    def purge
      ::FileUtils.rm(::Dir.glob(File.join(mydir, '*')))
    end

    def write_file(data, filename)
      logger.info "Backing up #{filename}"
      file = ::File.open(filename, 'w')
      file.write(data)
    ensure
      file.close
    end
  end
end
