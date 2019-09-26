module RightOn
  class ByGroup
    def self.rights
      new.by_groups
    end

    def initialize
      @rights_by_name = Hash[Right.all.map{|r| [r.name, r]}]
    end

    def by_groups
      yaml_rights.each_pair.with_object({}) { |(group, right_names), hash|
        hash[group] = right_names
          .flat_map { |right_name| right_name_to_rights(right_name) }
      }.sort.to_h
    end

    private

    def yaml_rights
      YAML.load_file(RightOn.rights_yaml)
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
      @rights_by_name[name] or fail RightOn::RightNotFound, name.inspect
    end
  end

  RightNotFound = Class.new(RightOn::Error)
end
