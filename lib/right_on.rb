module RightOn
  VERSION = '0.0.1'

  require 'active_record'

  require 'dependent_protect'
  require 'right_on/restricted_by_right'
  ActiveRecord::Base.send(:include, RestrictedByRight)

  require 'right_on/role_model'
  require 'right_on/right'
  require 'right_on/role'
  require 'right_on/action_controller_extensions'
end

