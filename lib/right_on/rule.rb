module RightOn
  class Rule
    def self.rule_for(right)
      self.new(right).call
    end

    def initialize(right)
      @right = right
    end

    def call
      validate!

      CanCan::Rule.new(can?, action, subject, conditions, nil)
    end

    private

    def validate!
      fail RightOn::Error, 'must specify an action' unless @right.action.present?
    end

    def can?
      @right.can
    end

    def action
      @right.action.to_sym
    end

    def subject
      model_class || @right.subject
    end

    def conditions
      model_class ? @right.conditions : nil
    end

    def model_class
      return nil unless @right.subject.present?

      begin
        model_class = self.class.const_get(@right.subject)
      rescue NameError
        model_class = Class
      end

      return model_class if model_class.ancestors.include?(ActiveRecord::Base)
    end
  end
end
