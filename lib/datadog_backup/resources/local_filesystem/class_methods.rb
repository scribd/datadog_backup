# frozen_string_literal: true

module DatadogBackup
  class Resources
    module LocalFilesystem
      module ClassMethods
        def all_files
          ::Dir.glob(::File.join($options[:backup_dir], '**', '*')).select { |f| ::File.file?(f) }
        end

        def all_file_ids
          all_files.map { |file| ::File.basename(file, '.*') }
        end

        def all_file_ids_for_selected_resources
          all_file_ids.select do |id|
            $options[:resources].include? class_from_id(id)
          end
        end

        def class_from_id(id)
          class_string = ::File.dirname(find_file_by_id(id)).split('/').last.capitalize
          ::DatadogBackup.const_get(class_string)
        end

        def find_file_by_id(id)
          idx = all_file_ids.index(id)
          return all_files[idx] if idx
          raise "Could not find file for #{id}"
        end

        def load_from_file_by_id(id)
          filepath = find_file_by_id(id)
          load_from_file(::File.read(filepath), file_type(filepath))
        end

        def mydir
          ::File.join($options[:backup_dir], myclass)
        end

        def purge
          ::FileUtils.rm(::Dir.glob(File.join(mydir, '*')))
        end

        private

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

        def file_type(filepath)
          ::File.extname(filepath).strip.downcase[1..].to_sym
        end
      end
    end
  end
end
