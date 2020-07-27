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

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dogapi', '~> 1.40'
  spec.add_dependency 'concurrent-ruby', '1.1.6'
  spec.add_dependency 'hashdiff', '1.0.1'
  spec.add_dependency 'amazing_print', '1.2.1'


  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
end
