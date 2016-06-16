require 'spec_helper'

describe RightOn::RoleModel do
  let(:admin_role) { RightOn::Role.create!(title: 'admin') }
  let(:product_right) { RightOn::Right.create!(name: 'Products', controller: 'products') }

  before do
    RightOn::Role.delete_all
    RightOn::Right.delete_all
    admin_role.rights << product_right
  end

  let(:basic_user) { User.create! }
  let(:admin) { User.create!(roles: [admin_role]) }

  it 'basic user should have no access' do
    expect(basic_user.rights).to be_empty
    expect(basic_user.has_right?('Products')).to be false
    expect(basic_user.has_right?(product_right)).to be false
  end

  it 'admin user should have full access' do
    expect(admin.rights.size).to eq 1
    expect(admin.has_right?('Products')).to be true
    expect(admin.has_right?(product_right)).to be true
  end

  it '#has_privileges_of?' do
    expect(admin.has_privileges_of?(basic_user)).to be true
    expect(basic_user.has_privileges_of?(admin)).to be false
  end

  context 'when associating rights of other objects' do
    let(:model1) { Model.create! }

    before do
      admin_role.rights << model1.right
    end

    it '#has_access_to?' do
      expect(admin.has_access_to?(model1)).to be true
      expect(basic_user.has_access_to?(model1)).to be false
    end
  end
end
