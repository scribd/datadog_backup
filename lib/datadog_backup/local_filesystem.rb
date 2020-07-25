require 'fileutils'
require 'json'
require 'yaml'

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
    
    def class_from_id(id)
      class_string = ::File.dirname(find_file_by_id(id)).split('/').last.capitalize
      ::DatadogBackup.const_get(class_string)
    end
    
    def dump(object)
      if output_format == :json
        JSON.pretty_generate(object)
      elsif output_format == :yaml
        YAML.dump(object)
      else
        raise "invalid output_format specified or not specified"
      end
    end

    def filename(id)
      ::File.join(mydir, "#{id}.#{output_format.to_s}")
    end

    def file_type(filepath)
      ::File.extname(filepath).strip.downcase[1..-1].to_sym
    end
    
    def find_file_by_id(id)
      ::Dir.glob(::File.join(backup_dir, '**', "#{id}.*")).first
    end
    
    def load_from_file(string, output_format)
      if output_format == :json
        JSON.load(string)
      elsif output_format == :yaml
        YAML.load(string)
      else
        raise "invalid output_format specified or not specified"
      end
    end
    
    def load_from_file_by_id(id)
      filepath = find_file_by_id(id)
      load_from_file(::File.read(filepath), file_type(filepath))
    end
    
    def mydir
      ::File.join(backup_dir,myclass)
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
