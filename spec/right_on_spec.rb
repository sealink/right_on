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

    @model = Model.create!(:name => 'Test')

    @users = Right.create!(:name => 'users', :controller => 'users')
    @other = Right.create!(:name => 'models', :controller => 'models')
    @index = Right.create!(:name => 'models#index', :controller => 'models', :action => 'index')
    @change = Right.create!(:name => 'models#change', :controller => 'models', :action => 'change')
    @view = Right.create!(:name => 'models#view', :controller => 'models', :action => 'view')
  end

  it 'should display nicely with sensible_name and to_s' do
    expect(@model.right.to_s).to eq 'Model: Test'
    expect(@other.to_s).to eq 'models'
    expect(@index.to_s).to eq 'models#index'

    expect(@model.right.sensible_name).to eq 'Model: Test'
    expect(@other.sensible_name).to eq 'Models'
    expect(@index.sensible_name).to eq 'Models - Index'
  end

  it 'should create right for restricted right' do
    right = @model.right
    expect(right).to_not be_nil
    expect(right.name).to eq 'Model: Test'
    expect{right.destroy}.to raise_error(ActiveRecord::DetailedDeleteRestrictionError)
  end

  it 'should identify correct groups' do
    rights = Right.regular_rights_with_group.sort_by{|r| r.name} # Sort for ruby 1.9 compatibility
    expect(rights.map(&:name)).to eq %w(models models#change models#index models#view users)
    expect(rights.map(&:group)).to eq %w(general general general general admin)

    expect(Right.by_groups).to eq(
      'general' => [@other, @index, @view, @change],
      'admin' => [@users],
      'other' => [@model.right]
    )
  end

  it 'should determine if it is allowed based on context' do
    index_action = {:controller => 'models', :action => 'index'}
    edit_action  = {:controller => 'models', :action => 'edit'}
    hello_action = {:controller => 'models', :action => 'hello'}

    expect(@model.right.allowed?(index_action)).to eq false

    expect(@users.allowed?(:controller => 'users', :action => 'index')).to eq true
    expect(@users.allowed?(:controller => 'users', :action => 'edit' )).to eq true
    expect(@users.allowed?(:controller => 'users', :action => 'hello')).to eq true

    expect(@other.allowed?(index_action)).to eq false # as specific action exists
    expect(@other.allowed?(edit_action )).to eq false # as specific action exists
    expect(@other.allowed?(hello_action)).to eq true # as hello isn't defined

    expect(@index.allowed?(index_action)).to eq true
    expect(@index.allowed?(edit_action )).to eq false
    expect(@index.allowed?(hello_action)).to eq false

    expect(@view.allowed?(index_action)).to eq true
    expect(@view.allowed?(edit_action )).to eq false
    expect(@view.allowed?(hello_action)).to eq false

    expect(@change.allowed?(index_action)).to eq true
    expect(@change.allowed?(edit_action )).to eq true
    expect(@change.allowed?(hello_action)).to eq false
  end
end

describe Right, "when created" do
  it "should validate presence of name" do
    subject.valid?
    expect(subject.errors[:name]).to_not be_blank
  end
end

describe Right, "with a name and controller" do
  before do
    @new_right = Right.new(:name => "tickets", :controller => "tickets")
    @new_right.save!
  end
  
  it "should create a new right" do
    expect(@new_right.name).to eq "tickets"
    expect(@new_right.controller).to eq "tickets"
    expect(@new_right.save).to eq true
  end
  
end

describe Right, "with a name, controller and action" do
  before do
    @new_right = Right.new(:name => "tickets@destroy", :controller => "tickets", :action => "destroy")
  end
   
  it "should create a new right" do
    expect(@new_right.name).to eq "tickets@destroy"
    expect(@new_right.controller).to eq "tickets"
    expect(@new_right.action).to eq "destroy"
    expect(@new_right.save).to eq true
  end
end

describe Right, "with only a name" do
  before do
    @new_right = Right.new(:name => "tickets2")
  end

  it "should create a new right" do
    expect(@new_right.save).to eq true
  end
end

describe Right, "with the same name" do
  before do
    @old_right = Right.new(:name => "tickets3", :controller => "tickets")
    @old_right.save!
    @new_right = Right.new(:name => "tickets3", :controller => "tickets")
  end

  it "should not create a new right" do
    expect(@new_right.save).to eq false
  end
end

describe Role, "can have many rights" do
  before do
    @r1 = Right.create!(:name => 'right 1')
    @r2 = Right.create!(:name => 'right 2')
    @d1 = Role.create!(:title => 'role 1')
    @d1.rights = [@r1, @r2]
  end

  it "should have and belong to many" do
    expect(@d1.rights.size).to eq 2
    expect(@r1.roles.size).to eq 1
  end
end
