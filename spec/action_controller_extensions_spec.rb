require 'spec_helper'

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

require 'action_controller'
class AdminController < ActionController::Base
  include RightOn::ActionControllerExtensions
  def current_user
    Thread.current[:user]
  end
end

describe AdminController do
  let(:basic_user) { User.where(name: 'basic').first }
  let(:admin_user) { User.where(name: 'admin').first }

  before do
    Bootstrap.reset_database
    controller.params = {controller: 'admin', action: 'index'}
  end

  let(:controller) { AdminController.new }
  context 'basic user' do
    before { Thread.current[:user] = basic_user }
    it 'should not allow access' do
      expect(controller.access_allowed?).to be false
    end
  end

  context 'admin user' do
    before { Thread.current[:user] = admin_user }
    it 'should allow access' do
      expect(controller.access_allowed?).to be true
    end
  end
end
