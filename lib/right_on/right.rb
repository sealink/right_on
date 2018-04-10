require 'active_record'

module RightOn
  class Right < ActiveRecord::Base

    has_and_belongs_to_many :roles, :class_name => 'RightOn::Role'

    validates_presence_of :name
    validates_uniqueness_of :name

    scope :ordered, -> { order :name }

    after_save :clear_cache
    after_destroy :clear_cache

    # Is this right allowed for the given context?
    #
    # Context params is an option hash:
    #   :controller => controller name
    #   :action     => action name
    #
    # The context tells us the state of the request being made.

    def allowed?(context={})
      return false unless controller == context[:controller]
      if action
        action_permitted?(context[:action])
      else
        # right without action works if no specific right exists
        # e.g. can't edit if there's a edit or change right defined
        # as you must used that specific right
        specific_rights = Array(APPLICABLE_RIGHTS[context[:action].to_sym]) + [context[:action]]
        specific_rights.all?{|action| Right["#{context[:controller]}##{action}"].nil?}
      end
    end

    APPLICABLE_RIGHTS = {
      :new     => [:change],
      :edit    => [:change],
      :update  => [:change],
      :create  => [:change],
      :destroy => [:change],
      :index   => [:change, :view],
      :show    => [:change, :view]
    }

    CHANGE_ACTIONS = %w(new edit update create destroy index show)

    VIEW_ACTIONS = %w(index show)

    def action_permitted?(context_action)
      case action.to_sym
      when :change
        CHANGE_ACTIONS.include?(context_action)
      when :view
        VIEW_ACTIONS.include?(context_action)
      else
        action == context_action
      end
    end

    def sensible_name
      name.humanize.titleize.gsub(/#/, ' - ')
    end

    def to_s
      name
    end

    def self.cache
      @@cache ||= Rails.cache
    end

    def self.cache=(cache)
      @@cache = cache
    end

    def self.clear_cache
      cache.delete('Right.all')
    end

    def clear_cache
      self.class.clear_cache
    end

    attr_accessor :rights
    def self.[](name)
      @rights = cache.read('Right.all') || calculate_and_write_cache
      @rights[name]
    end

    private
    def self.calculate_and_write_cache
      right_cache = Hash[Right.all.map{|r|[r.name, r.id]}]
      cache.write('Right.all', right_cache) or raise RuntimeError, "Could not cache rights"
      right_cache
    end

  end
end
