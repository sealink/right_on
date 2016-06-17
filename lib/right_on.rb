module RightOn
  require 'active_record'

  require 'dependent_restrict'
  require 'right_on/restricted_by_right'
  ActiveRecord::Base.send(:include, RestrictedByRight)

  require 'rails'
  require 'right_on/railtie'
  require 'right_on/rights_manager'
end

