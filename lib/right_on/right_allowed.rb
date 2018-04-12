module RightOn
  class RightAllowed
    def initialize(controller, action)
      @controller = controller
      @action = action
    end

    def allowed?(right)
      return false unless right.controller == @controller
      if right.action
        action_permitted?(right.action)
      else
        # right without action works if no specific right exists
        # e.g. can't edit if there's a edit or change right defined
        # as you must used that specific right
        specific_rights = Array(APPLICABLE_RIGHTS[@action.to_sym]) + [@action]
        specific_rights.all?{|action| self.class["#{@controller}##{action}"].nil?}
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

    def action_permitted?(action)
      case action.to_sym
      when :change
        CHANGE_ACTIONS.include?(@action)
      when :view
        VIEW_ACTIONS.include?(@action)
      else
        action == @action
      end
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

    attr_accessor :rights
    def self.[](name)
      @rights = cache.read('Right.all') || calculate_and_write_cache
      @rights[name]
    end

    private
    def self.calculate_and_write_cache
      right_cache = Hash[RightOn::Right.all.map{|r|[r.name, r.id]}]
      cache.write('Right.all', right_cache) or raise RuntimeError, "Could not cache rights"
      right_cache
    end
  end
end