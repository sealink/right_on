require 'active_record'

class RightAssignment < ActiveRecord::Base
  self.table_name = :rights_roles

  belongs_to :right
  belongs_to :role
end
