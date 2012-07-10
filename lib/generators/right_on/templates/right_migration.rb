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
    Right.create(
      :controller   => '<%= right_controller %>'.presence, 
      :action       => '<%= right_action %>'.presence, 
      :name         => '<%= right_name %>'.presence, 
      :roles        => Role.all(:conditions => {:title => [<%= right_roles.map { |r| "'#{r}'"}.join(',') %>]}))
  end
  
  
  def self.down
    Right.destroy_all(:name => '<%= right_name %>')
  end
  
end
