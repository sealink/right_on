module RightOn
  module Ability
    include CanCan::Ability

    private def add_rule_for(right)
      add_rule(RightOn::Rule.rule_for(right))
    end
  end
end
