class Bootstrap
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
    RightOn::Right.create!(build_right_attrs(name))
  end

  def self.build_right_attrs(name)
    if name['#']
      controller, action = name.split('#')
      { name: name, controller: controller, action: action }
    else
      { name: name, controller: name }
    end
  end
end
