require 'spec_helper'

RightOn::Right.rights_yaml 'db/rights_roles.yml'

describe RightOn::ByGroup do
  let(:rights) { Bootstrap.various_rights_with_actions }

  it 'should identify correct groups' do
    rights # load rights
    expect(RightOn::Right.by_groups).to eq(
      'general' => [
        rights[:models],
        rights[:models_index],
        rights[:models_view],
        rights[:models_change]
      ],
      'admin' => [
        rights[:users]
      ]
    )
  end
end
