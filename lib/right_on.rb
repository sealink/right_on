module RightOn
  VERSION = '0.0.1'

  require 'active_record'

  require 'dependent_protect'
  require 'right_on/restricted_by_right'
  ActiveRecord::Base.send(:include, RestrictedByRight)

  require 'right_on/railtie' if defined?(Rails::Railtie)
  require 'right_on/rights_manager'
end

