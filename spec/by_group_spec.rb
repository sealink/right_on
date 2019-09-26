require 'spec_helper'

RightOn.rights_yaml 'db/rights.yml'

describe RightOn::ByGroup do
  let(:rights) { Bootstrap.various_rights_with_actions }

  before do
    rights
  end

  it 'should be sorted' do
    expect(RightOn::ByGroup.rights.keys).to eq ['admin', 'general']
  end

  it 'should identify correct groups' do
    expect(RightOn::ByGroup.rights).to eq(
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
