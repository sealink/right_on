require 'spec_helper'

describe RightOn::Right do
  let(:rights) { Bootstrap.various_rights_with_actions }
  let(:users)  { rights[:users] }
  let(:other)  { rights[:models] }
  let(:index)  { rights[:models_index] }
  let(:change) { rights[:models_change] }
  let(:view)   { rights[:models_view] }

  it 'should display nicely with sensible_name and to_s' do
    expect(other.to_s).to eq 'models'
    expect(index.to_s).to eq 'models#index'

    expect(other.sensible_name).to eq 'Models'
    expect(index.sensible_name).to eq 'Models - Index'
  end

  it 'should determine if it is allowed based on context' do
    index_action = { controller: 'models', action: 'index' }
    edit_action  = { controller: 'models', action: 'edit' }
    hello_action = { controller: 'models', action: 'hello' }

    expect(users.allowed?(controller: 'users', action: 'index')).to eq true
    expect(users.allowed?(controller: 'users', action: 'edit')).to eq true
    expect(users.allowed?(controller: 'users', action: 'hello')).to eq true

    expect(other.allowed?(index_action)).to eq false # as specific action exists
    expect(other.allowed?(edit_action )).to eq false # as specific action exists
    expect(other.allowed?(hello_action)).to eq true # as hello isn't defined

    expect(index.allowed?(index_action)).to eq true
    expect(index.allowed?(edit_action )).to eq false
    expect(index.allowed?(hello_action)).to eq false

    expect(view.allowed?(index_action)).to eq true
    expect(view.allowed?(edit_action )).to eq false
    expect(view.allowed?(hello_action)).to eq false

    expect(change.allowed?(index_action)).to eq true
    expect(change.allowed?(edit_action )).to eq true
    expect(change.allowed?(hello_action)).to eq false
  end
end

describe RightOn::Right, 'when created' do
  it 'should validate presence of name' do
    subject.valid?
    expect(subject.errors[:name]).to_not be_blank
  end
end

describe RightOn::Right, 'with a name and controller' do
  before do
    @new_right = RightOn::Right.new(name: 'tickets', controller: 'tickets')
    @new_right.save!
  end

  it 'should create a new right' do
    expect(@new_right.name).to eq 'tickets'
    expect(@new_right.controller).to eq 'tickets'
    expect(@new_right.save).to eq true
  end

end

describe RightOn::Right, 'with a name, controller and action' do
  before do
    @new_right = RightOn::Right.new(name: 'tickets@destroy', controller: 'tickets', action: 'destroy')
  end

  it 'should create a new right' do
    expect(@new_right.name).to eq 'tickets@destroy'
    expect(@new_right.controller).to eq 'tickets'
    expect(@new_right.action).to eq 'destroy'
    expect(@new_right.save).to eq true
  end
end

describe RightOn::Right, 'with only a name' do
  before do
    @new_right = RightOn::Right.new(name: 'tickets2')
  end

  it 'should create a new right' do
    expect(@new_right.save).to eq true
  end
end

describe RightOn::Right, 'with the same name' do
  before do
    @old_right = RightOn::Right.new(name: 'tickets3', controller: 'tickets')
    @old_right.save!
    @new_right = RightOn::Right.new(name: 'tickets3', controller: 'tickets')
  end

  it 'should not create a new right' do
    expect(@new_right.save).to eq false
  end
end

describe RightOn::Role, 'can have many rights' do
  let(:role1) { RightOn::Role.new(title: 'role 1') }

  specify { expect(role1.to_s).to eq 'Role 1' }

  context 'when assigned rights' do
    let(:right1) { RightOn::Right.create!(name: 'right 1') }
    let(:right2) { RightOn::Right.create!(name: 'right 2') }

    before do
      role1.save!
      role1.rights = [right1, right2]
    end

    after do
      role1.destroy
      right1.destroy
      right2.destroy
    end

    it 'should have and belong to many' do
      expect(role1.rights.size).to eq 2
      expect(right1.roles.size).to eq 1
      expect(right2.roles.size).to eq 1
    end
  end
end

describe 'when checking accessibility to a controller' do

  let(:test_controller_right) { RightOn::Right.new(name: 'test', controller: 'test') }
  let(:user) { double(rights: [test_controller_right]) }
  let(:controller) { 'test' }
  let(:action) { 'index' }
  let(:params) { {controller: 'test', action: 'index'} }

  before do
    stub_const 'TestController', double(current_user: user, params: params)
    TestController.extend RightOn::ActionControllerExtensions
    allow(TestController).to receive(:rights_from).and_return(nil)
  end

  specify { expect(TestController.access_allowed?(controller)).to be_truthy }
  specify { expect(TestController.access_allowed?('other')).to be_falsey }
  specify { expect(TestController.access_allowed_to_controller?(controller)).to be_truthy }
  specify { expect(TestController.access_allowed_to_controller?('other')).to be_falsey }

  describe 'when inheriting rights' do
    let(:controller) { 'test_inherited' }

    before do
      stub_const 'TestInheritedController', double(current_user: user, params: params)
      TestInheritedController.extend RightOn::ActionControllerExtensions
      allow(TestInheritedController).to receive(:rights_from).and_return(:test)
    end

    specify { expect(TestInheritedController.access_allowed?(controller)).to be_falsey }
    specify { expect(TestInheritedController.access_allowed?('other')).to be_falsey }
    specify { expect(TestInheritedController.access_allowed_to_controller?(controller)).to be_truthy }
    specify { expect(TestInheritedController.access_allowed_to_controller?('other')).to be_falsey }
  end
end
