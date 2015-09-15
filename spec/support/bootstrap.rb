class Bootstrap
  def self.reset_database
    Right.delete_all
    Role.delete_all
    User.delete_all

    basic_right = Right.create!(:name => 'basic', :controller => 'basic')
    admin_right = Right.create!(:name => 'admin', :controller => 'admin')
    basic_role = Role.create!(:title => 'Basic', :rights => [basic_right])
    admin_role = Role.create!(:title => 'Admin', :rights => [admin_right])

    basic_user = User.create!(name: 'basic', roles: [basic_role])
    admin_user = User.create!(name: 'admin', roles: [basic_role, admin_role])
  end
end
