module RightOn
  VERSION = '0.0.1'

  require 'active_record'

  require 'dependent_restrict'
  require 'right_on/restricted_by_right'
  ActiveRecord::Base.send(:include, RestrictedByRight)

  begin
    require 'rails'
  rescue LoadError # if rails2
    require 'initializer'
  end
  if defined?(Rails::Railtie)
    require 'right_on/railtie'
    require 'right_on/rights_manager'
  end
end

