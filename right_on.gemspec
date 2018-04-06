# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'right_on/version'

Gem::Specification.new do |spec|
  spec.name          = 'right_on'
  spec.version       = RightOn::VERSION
  spec.authors       = ["Michael Noack", "Alessandro Berardi"]
  spec.email         = 'development@travellink.com.au'
  spec.description   = "This helps systems manage rights and roles on a controller/action basis."
  spec.summary       = "Set of extensions to core rails to give rights and roles."
  spec.homepage      = 'http://github.com/sealink/right_on'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'activesupport', '>= 4.0.0'
  spec.add_dependency 'input_reader', '~> 0.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'coverage-kit'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'travis'
end
