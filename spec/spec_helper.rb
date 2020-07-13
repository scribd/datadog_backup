$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require 'datadog_sync'

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
WORK_ROOT = File.expand_path(File.join(SPEC_ROOT, '..'))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  config.example_status_persistence_file_path = File.join(SPEC_ROOT, 'helpers', 'failures.txt')

  Kernel.srand config.seed
end
