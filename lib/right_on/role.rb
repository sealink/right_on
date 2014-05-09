class Role < ActiveRecord::Base

  has_many :right_assignments
  has_many :rights, :through => :right_assignments

  validates_presence_of :title
  validates_uniqueness_of :title

  def to_s
    self.title.try(:titleize)
  end

  alias_method :name, :to_s

end
