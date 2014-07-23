require 'active_record'

class RightAssignment < ActiveRecord::Base
  self.table_name = :rights_roles
  self.primary_key = [:right_id, :role_id]

  belongs_to :right
  belongs_to :role
end
