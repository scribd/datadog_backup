# frozen_string_literal: true

module DatadogBackup
  # Notify the user if they are using deprecated features.
  module Deprecations
    def self.check
      LOGGER.warn "ruby-#{RUBY_VERSION} is deprecated. Ruby 3.1 or higher will be required to use this gem after datadog_backup@v3" if RUBY_VERSION < '3.1'
    end
  end
end
