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
