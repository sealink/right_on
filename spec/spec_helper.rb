# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rubygems'
require 'bundler/setup'

require 'support/bootstrap'
require 'support/coverage_loader'

require 'right_on'
require 'right_on/rails'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.before :all do
    Right.cache = ActiveSupport::Cache::MemoryStore.new
  end
end

DB_FILE = 'tmp/test_db'
FileUtils.mkdir_p File.dirname(DB_FILE)
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE

load('spec/schema.rb')

Right.rights_yaml 'db/rights_roles.yml'

class Model < ActiveRecord::Base
  restricted_by_right
end

class User < ActiveRecord::Base
  include RightOn::RoleModel
end
