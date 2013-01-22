class Role < ActiveRecord::Base

  has_and_belongs_to_many :rights

  validates_presence_of :title
  validates_uniqueness_of :title

  def to_s
    self.title.try(:titleize)
  end

  alias_method :name, :to_s

end
