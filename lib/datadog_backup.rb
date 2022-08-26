# frozen_string_literal: true

require 'concurrent'

require_relative 'datadog_backup/local_filesystem'
require_relative 'datadog_backup/options'
require_relative 'datadog_backup/cli'
require_relative 'datadog_backup/core'
require_relative 'datadog_backup/dashboards'
require_relative 'datadog_backup/monitors'
require_relative 'datadog_backup/synthetics'
require_relative 'datadog_backup/thread_pool'
require_relative 'datadog_backup/version'
require_relative 'datadog_backup/deprecations'
DatadogBackup::Deprecations.check


module DatadogBackup
end

