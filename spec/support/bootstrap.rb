class Bootstrap
  def self.reset_database
    RightOn::Right.delete_all
    RightOn::Role.delete_all
    User.delete_all

    basic_right = RightOn::Right.create!(:name => 'basic', :controller => 'basic')
    admin_right = RightOn::Right.create!(:name => 'admin', :controller => 'admin')
    basic_role  = RightOn::Role.create!(:title => 'Basic', :rights => [basic_right])
    admin_role  = RightOn::Role.create!(:title => 'Admin', :rights => [admin_right])

    User.create!(name: 'basic', roles: [basic_role])
    User.create!(name: 'admin', roles: [basic_role, admin_role])
  end
end
