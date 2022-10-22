# frozen_string_literal: true

require 'concurrent'

require_relative 'datadog_backup/cli'
require_relative 'datadog_backup/client'
require_relative 'datadog_backup/thread_pool'

require_relative 'datadog_backup/resources/local_filesystem/class_methods'
require_relative 'datadog_backup/resources/local_filesystem'
require_relative 'datadog_backup/resources'

require_relative 'datadog_backup/dashboards'
require_relative 'datadog_backup/monitors'
require_relative 'datadog_backup/synthetics'

require_relative 'datadog_backup/version'
require_relative 'datadog_backup/deprecations'

DatadogBackup::Deprecations.check

# DatadogBackup is a gem for backing up and restoring Datadog monitors and dashboards.
module DatadogBackup
end
