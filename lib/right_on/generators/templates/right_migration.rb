class Right < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates_presence_of :name
  validates_uniqueness_of :name
end

class Role < ActiveRecord::Base
  has_and_belongs_to_many :rights

  validates_presence_of :title
  validates_uniqueness_of :title
end


class Add<%= parsed_right_name.camelize %>Right < ActiveRecord::Migration
  
  def self.up
    right_for_roles = Right.find_by_name("<%= right_for_roles %>")
    Right.create(
      :controller => '<%= right_controller %>'.presence,
      :action     => '<%= right_action %>'.presence,
      :name       => '<%= right_name %>'.presence,
      :roles      => right_for_roles.roles
    )
  end
  
  
  def self.down
    Right.destroy_all(:name => '<%= right_name %>')
  end
  
end
