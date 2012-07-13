class Railtie < Rails::Railtie
  initializer 'right_on.initialize' do
    ActiveSupport.on_load(:active_record) do
      require 'right_on/rails'
    end
  end

  rake_tasks do
    load "right_on/tasks/seeds_rights.rake"
    load "right_on/tasks/rights_roles.rake"
  end
end
