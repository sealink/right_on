class Railtie < Rails::Railtie
  initializer 'right_on.initialize' do
    ActiveSupport.on_load(:active_record) do
      require 'right_on/rails'
    end
  end
end
