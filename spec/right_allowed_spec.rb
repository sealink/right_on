require 'active_record'
require 'active_support/cache/memory_store'
require 'right_on/right'
require 'right_on/right_allowed'
require 'spec_helper'
require 'support/bootstrap'

describe RightOn::RightAllowed do
  def right_double(name)
    default_attrs = { id: rand(1_000_000), action: nil }
    double default_attrs.merge(Bootstrap.build_right_attrs(name))
  end

  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    stub_const 'Rails', double(cache: cache)
    RightOn::RightAllowed.clear_cache
    stub_const 'RightOn::Right', double(all: all)
  end

  context 'for simple case with one controller right' do
    let(:all) { [users] }
    let(:users) { right_double('users') }

    subject { RightOn::RightAllowed.new('users', action).allowed?(users) }

    context 'index action' do
      let(:action) { 'index' }
      it { is_expected.to be true }
    end

    context 'edit action' do
      let(:action) { 'edit' }
      it { is_expected.to be true }
    end

    context 'hello action' do
      let(:action) { 'hello' }
      it { is_expected.to be true }
    end
  end

  context 'for complex rights' do
    let(:all) { [other, index, change, view] }

    let(:index_action) { RightOn::RightAllowed.new('models', 'index') }
    let(:edit_action)  { RightOn::RightAllowed.new('models', 'edit')  }
    let(:hello_action) { RightOn::RightAllowed.new('models', 'hello') }

    let(:other)  { right_double('models') }
    let(:index)  { right_double('models#index') }
    let(:change) { right_double('models#change') }
    let(:view)   { right_double('models#view') }

    context 'index action' do
      specify do
        # as specific action exists
        expect(index_action.allowed?(other)).to eq false

        expect(index_action.allowed?(index)).to eq true
        expect(index_action.allowed?(view)).to eq true
        expect(index_action.allowed?(change)).to eq true
      end
    end

    context 'edit action' do
      specify do
        # as specific action exists
        expect(edit_action.allowed?(other)).to eq false

        expect(edit_action.allowed?(index)).to eq false
        expect(edit_action.allowed?(view)).to eq false
        expect(edit_action.allowed?(change)).to eq true
      end
    end

    context 'hello action' do
      specify do
        # as hello isn't defined
        expect(hello_action.allowed?(other)).to eq true

        expect(hello_action.allowed?(index)).to eq false
        expect(hello_action.allowed?(view)).to eq false
        expect(hello_action.allowed?(change)).to eq false
      end
    end
  end
end
