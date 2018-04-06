class Bootstrap
  def self.reset_database
    RightOn::Right.delete_all
    RightOn::Role.delete_all
    User.delete_all

    basic_right = RightOn::Right.create!(name: 'basic', controller: 'basic')
    admin_right = RightOn::Right.create!(name: 'admin', controller: 'admin')
    basic_role  = RightOn::Role.create!(title: 'Basic', rights: [basic_right])
    admin_role  = RightOn::Role.create!(title: 'Admin', rights: [admin_right])

    User.create!(name: 'basic', roles: [basic_role])
    User.create!(name: 'admin', roles: [basic_role, admin_role])
  end

  def self.various_rights_with_actions
    RightOn::Right.delete_all
    {
      users:         create_right('users'),
      models:        create_right('models'),
      models_index:  create_right('models#index'),
      models_change: create_right('models#change'),
      models_view:   create_right('models#view')
    }
  end

  def self.create_right(name)
    if name['#']
      controller, action = name.split('#')
      RightOn::Right.create!(name: name, controller: controller, action: action)
    else
      RightOn::Right.create!(name: name, controller: name)
    end
  end
end
