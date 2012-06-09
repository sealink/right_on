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

describe Right do
  before do
    Right.delete_all
    Model.delete_all

    Right.stub!(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)

    @model = Model.create!(:name => 'Test')

    @users = Right.create!(:name => 'users', :controller => 'users')
    @other = Right.create!(:name => 'models', :controller => 'models')
    @index = Right.create!(:name => 'models#index', :controller => 'models', :action => 'index')
    @change = Right.create!(:name => 'models#change', :controller => 'models', :action => 'change')
    @view = Right.create!(:name => 'models#view', :controller => 'models', :action => 'view')
  end

  it 'should display nicely with sensible_name and to_s' do
    @model.right.to_s.should == 'Model: Test'
    @other.to_s.should == 'models'
    @index.to_s.should == 'models#index'

    @model.right.sensible_name.should == 'Model: Test'
    @other.sensible_name.should == 'Models'
    @index.sensible_name.should == 'Models - Index'
  end

  it 'should create right for restricted right' do
    right = @model.right
    right.should_not be_nil
    right.name.should == 'Model: Test'
    lambda{right.destroy}.should raise_error(ActiveRecord::DeleteRestrictionError)
  end

  it 'should identify correct groups' do
    rights = Right.regular_rights_with_group.sort_by{|r| r.name} # Sort for ruby 1.9 compatibility
    rights.map(&:name).should == %w(models models#change models#index models#view users)
    rights.map(&:group).should == %w(general general general general admin)

    Right.by_groups.should == {
      'general' => [@other, @index, @view, @change],
      'admin' => [@users],
      'other' => [@model.right]
    }
  end

  it 'should determine if it is allowed based on context' do
    index_action = {:controller => 'models', :action => 'index'}
    edit_action  = {:controller => 'models', :action => 'edit'}
    hello_action = {:controller => 'models', :action => 'hello'}

    @model.right.allowed?(index_action).should be_false

    @users.allowed?(:controller => 'users', :action => 'index').should be_true
    @users.allowed?(:controller => 'users', :action => 'edit' ).should be_true
    @users.allowed?(:controller => 'users', :action => 'hello').should be_true

    @other.allowed?(index_action).should be_false # as specific action exists
    @other.allowed?(edit_action ).should be_false # as specific action exists
    @other.allowed?(hello_action).should be_true # as hello isn't defined

    @index.allowed?(index_action).should be_true
    @index.allowed?(edit_action ).should be_false
    @index.allowed?(hello_action).should be_false

    @view.allowed?(index_action).should be_true
    @view.allowed?(edit_action ).should be_false
    @view.allowed?(hello_action).should be_false

    @change.allowed?(index_action).should be_true
    @change.allowed?(edit_action ).should be_true
    @change.allowed?(hello_action).should be_false
  end
end
