require 'spec_helper'

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
