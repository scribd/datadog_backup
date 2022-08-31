# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog_backup/version'

Gem::Specification.new do |spec|
  spec.name          = 'datadog_backup'
  spec.version       = DatadogBackup::VERSION
  spec.authors       = ['Kamran Farhadi', 'Jim Park']
  spec.email         = ['kamranf@scribd.com', 'jimp@scribd.com']
  spec.summary       = 'A utility to backup and restore Datadog accounts'
  spec.description   = 'A utility to backup and restore Datadog accounts'
  spec.homepage      = 'https://github.com/scribd/datadog_backup'
  spec.license       = 'MIT'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'amazing_print'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'deepsort'
  spec.add_dependency 'diffy'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday-retry'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
