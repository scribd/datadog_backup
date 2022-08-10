

module DatadogBackup
  module Deprecations
    def self.check
      if RUBY_VERSION < '2.7'
        LOGGER.warn "ruby-#{RUBY_VERSION} is deprecated. Ruby 2.7 or higher will be required to use this gem after datadog_backup@v3"
      end
    end
  end
end