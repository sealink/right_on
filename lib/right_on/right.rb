require 'active_record'

module RightOn
  class Right < ActiveRecord::Base

    has_and_belongs_to_many :roles, :class_name => 'RightOn::Role'

    validates_presence_of :name
    validates_uniqueness_of :name

    scope :ordered, -> { order :name }

    after_save { RightOn::RightAllowed.clear_cache }
    after_destroy { RightOn::RightAllowed.clear_cache }

    def sensible_name
      name.humanize.titleize.gsub(/#/, ' - ')
    end

    def to_s
      name
    end
  end
end
