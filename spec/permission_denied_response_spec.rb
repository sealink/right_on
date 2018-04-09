require 'spec_helper'

describe RightOn::PermissionDeniedResponse do
  let(:controller_action_options) { { controller: 'users', action: 'destroy' } }
  let(:params) { { controller: 'users' } }
  subject { RightOn::PermissionDeniedResponse.new(params, controller_action_options) }

  let(:create_user_right) { double(name: 'create_user', allowed?: true, roles: [double(title: 'Users')]) }
  let(:allowed) { double(allowed?: true) }
  let(:denied) { double(allowed?: false) }

  let(:no_right_for_page) {
    'No right is defined for this page: users. '\
    'Contact your system manager to notify this problem.'
  }
  let(:no_roles_for_page) { 'N/A (as no right is assigned for this action)' }

  before do
    stub_const 'RightOn::RightAllowed', double(new: right_allowed)
    stub_const 'RightOn::Right', double(all: [create_user_right])
  end

  context '#text_message' do
    context 'when right exists' do
      let(:right_allowed) { allowed }

      specify {
        expect(subject.text_message).to eq(
          "You are not authorised to perform the requested operation.\n"\
          "Right required: #[Double (anonymous)]\n"\
          "This right is given to the following roles: Users.\n"\
          "Contact your system manager to be given this right.\n"
        )
      }
    end

    context 'when right not allowed' do
      let(:right_allowed) { denied }
      specify { expect(subject.text_message).to eq no_right_for_page }
    end
  end

  context '#to_json' do
    context 'when right exists' do
      let(:right_allowed) { allowed }
      specify {
        expect(subject.to_json).to eq(
          error: 'Permission Denied',
          right_allowed: 'create_user',
          roles_for_right: ['Users']
        )
      }
    end

    context 'when right allowed' do
      let(:right_allowed) { denied }
      specify {
        expect(subject.to_json).to eq(
          error: 'Permission Denied',
          right_allowed: no_right_for_page,
          roles_for_right: no_roles_for_page
        )
      }
    end
  end
end
