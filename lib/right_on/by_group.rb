module RightOn
  class ByGroup
    def initialize
      @rights_by_name = Hash[Right.all.map{|r| [r.name, r]}]
    end

    def by_groups
      rights = regular_rights_with_group
      rights += (Right.all - rights)
      rights.group_by(&:group)
    end

    private

    def regular_rights_with_group
      RightOn::Right.yaml_rights.each_pair.flat_map do |group, right_names|
        right_names
          .flat_map { |right_name| right_name_to_rights(right_name) }
          .each { |r| r.group = group }
      end
    end

    def right_name_to_rights(right_name)
      case right_name
      when String # controller
        [rights_by_name!(right_name)]
      when Hash # controller + actions
        controller, actions = right_name.first
        controller_rights(controller) + action_rights(controller, actions)
      end
    end

    def controller_rights(controller)
      r = @rights_by_name[controller]
      return [] unless r
      [r]
    end

    def action_rights(controller, actions)
      actions.map { |action| rights_by_name!("#{controller}##{action}") }
    end

    def rights_by_name!(name)
      @rights_by_name[name] or fail name.inspect
    end
  end
end
