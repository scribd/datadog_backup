# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'
require 'deepsort'

module DatadogBackup
  class Resources
    ##
    # Meant to be mixed into DatadogBackup::Resources
    # Relies on $options[:backup_dir] and $options[:output_format]
    module LocalFilesystem
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Write to backup file
      def backup
        ::FileUtils.mkdir_p(mydir)
        write_file(dump, filename)
      end

      def delete_backup
        ::FileUtils.rm(filename)
      end

      def body_from_backup
        sanitize(self.class.load_from_file_by_id(@id))
      end

      def filename
        ::File.join(mydir, "#{@id}.#{$options[:output_format]}")
      end

      private

      def mydir
        self.class.mydir
      end

      def write_file(data, filename)
        LOGGER.info "Backing up #{filename}"
        file = ::File.open(filename, 'w')
        file.write(data)
      ensure
        file.close
      end
    end
  end
end
