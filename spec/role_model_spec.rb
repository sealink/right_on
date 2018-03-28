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
  end

  it 'admin user should have full access' do
    expect(admin.rights.size).to eq 1
  end

  it '#has_privileges_of?' do
    expect(admin.has_privileges_of?(basic_user)).to be true
    expect(basic_user.has_privileges_of?(admin)).to be false
  end

  it 'links back to users' do
    admin # load admin
    expect(admin_role.users.size).to eq 1
  end
end
