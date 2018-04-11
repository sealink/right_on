require 'active_record'
require 'active_support/cache/memory_store'
require 'right_on/right'
require 'right_on/right_allowed'
require 'spec_helper'

describe RightOn::RightAllowed do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    stub_const 'Rails', double(cache: cache)
    RightOn::RightAllowed.clear_cache
    stub_const 'RightOn::Right', double(all: all)
  end

  context 'for simple case with one controller right' do
    let(:all) { [users] }
    let(:users)  { double(id: 1, name: 'name', controller: 'users', action: nil) }

    it 'should allow all actions' do
      expect(RightOn::RightAllowed.new('users', 'index').allowed?(users)).to be true
      expect(RightOn::RightAllowed.new('users', 'edit' ).allowed?(users)).to be true
      expect(RightOn::RightAllowed.new('users', 'hello').allowed?(users)).to be true
    end
  end

  context 'for complex rights' do
    let(:all) { [other, index, change, view] }

    let(:index_action) { RightOn::RightAllowed.new('models', 'index') }
    let(:edit_action)  { RightOn::RightAllowed.new('models', 'edit')  }
    let(:hello_action) { RightOn::RightAllowed.new('models', 'hello') }

    let(:other)  { double(id: 2, name: 'models',        controller: 'models', action: nil)      }
    let(:index)  { double(id: 3, name: 'models#index',  controller: 'models', action: 'index')  }
    let(:change) { double(id: 4, name: 'models#change', controller: 'models', action: 'change') }
    let(:view)   { double(id: 5, name: 'models#view',   controller: 'models', action: 'view')   }

    context 'index action' do
      specify do
        expect(index_action.allowed?(other)).to eq false # as specific action exists
        expect(index_action.allowed?(index)).to eq true
        expect(index_action.allowed?(view)).to eq true
        expect(index_action.allowed?(change)).to eq true
      end
    end

    context 'edit action' do
      specify do
        expect(edit_action.allowed?(other)).to eq false # as specific action exists
        expect(edit_action.allowed?(index)).to eq false
        expect(edit_action.allowed?(view)).to eq false
        expect(edit_action.allowed?(change)).to eq true
      end
    end

    context 'hello action' do
      specify do
        expect(hello_action.allowed?(other)).to eq true # as hello isn't defined
        expect(hello_action.allowed?(index)).to eq false
        expect(hello_action.allowed?(view)).to eq false
        expect(hello_action.allowed?(change)).to eq false
      end
    end
  end
end
