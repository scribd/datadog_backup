# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "datadog_sync"
  spec.version       = DatadogSync::VERSION
  spec.authors       = ["Kamran Farhadi", "Jim Park"]
  spec.email         = ["kamranf@scribd.com", "jimp@scribd.com"]
  spec.summary       = %q{A utility to backup and restore Datadog accounts}
  spec.description   = %q{A utility to backup and restore Datadog accounts}
  spec.homepage      = "https://github.com/scribd/datadog_sync"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'dogapi', '~> 1.40'
  spec.add_dependency 'multi_json'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
end
