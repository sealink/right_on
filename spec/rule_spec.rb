require 'active_record'
require 'active_support/all'
require 'cancan/rule'
require 'right_on/error'
require 'right_on/rule'
require 'spec_helper'

describe RightOn::Rule do
  subject(:rule) { RightOn::Rule.rule_for(right) }

  describe '#self.rule_for' do
    let(:right) {
      double(name: 'Do Something', can: true, action: 'action', subject: 'subject', conditions: {})
    }

    it 'should return a cancan rule' do
      is_expected.to be_a(CanCan::Rule)
    end
  end

  describe '#call' do
    context 'when an action is not specified' do
      let(:right) {
        double(name: 'Do Something', can: true, action: nil, subject: 'subject', conditions: {})
      }

      it 'should fail with exception' do
        expect{rule}.to raise_error(RightOn::Error, 'must specify an action')
      end
    end

    context 'when the subject is not a model' do
      let(:right) {
        double(name: 'Do Something', can: true, action: 'action', subject: 'subject', conditions: {})
      }

      it 'should return a CanCan::Rule' do
        is_expected.to be_a(CanCan::Rule)
      end

      it 'should convert the action to a symbol' do
        expect(rule.actions).to eq([:action])
      end

      it 'should set the subject' do
        expect(rule.subjects).to eq(['subject'])
      end

      it 'should not have any conditions' do
        expect(rule.conditions).to eq({})
      end
    end

    context 'when the subject is a model' do
      let(:right) {
        double(name: 'Do Something', can: true, action: 'action', subject: 'Model', conditions: {})
      }

      before do
        class Model < ActiveRecord::Base
        end
      end

      it 'should return a CanCan::Rule' do
        is_expected.to be_a(CanCan::Rule)
      end

      it 'should convert the action to a symbol' do
        expect(rule.actions).to eq([:action])
      end

      it 'should convert the subject to a model' do
        expect(rule.subjects).to eq([Model])
      end

      it 'should not have any conditions' do
        expect(rule.conditions).to eq({})
      end
    end
  end
end
