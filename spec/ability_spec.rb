require 'active_support/all'
require 'cancan/ability'
require 'right_on/error'
require 'right_on/rule'
require 'right_on/ability'
require 'spec_helper'

describe RightOn::Ability do
  describe 'private #add_rule_for' do
    subject(:ability) {
      class TestAbility
        include RightOn::Ability
      end

      TestAbility.new
    }
    let(:right) {
      double(name: 'Do Something', can: true, action: 'action', subject: 'subject', conditions: {})
    }

    before do
      ability.send(:add_rule_for, right)
    end

    it 'should add a rule to the ability' do
      expect(ability.send(:rules).count).to eq(1)
    end
  end
end
