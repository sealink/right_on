# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rubygems'
require 'bundler/setup'

MINIMUM_COVERAGE = 63

unless ENV['COVERAGE'] == 'off'
  require 'simplecov'
  require 'simplecov-rcov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/spec/'
    add_group 'lib', 'lib'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    unless percent >= MINIMUM_COVERAGE
      puts "Coverage must be above #{MINIMUM_COVERAGE}%. It is #{"%.2f" % percent}%"
      Kernel.exit(1)
    end
  end
end

require 'right_on'
require 'right_on/rails'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.before :all do
    Right.cache = ActiveSupport::Cache::MemoryStore.new
  end
end
