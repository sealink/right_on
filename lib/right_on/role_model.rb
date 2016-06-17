module RightOn
  module RoleModel
    def self.included(base)
      base.module_eval 'has_and_belongs_to_many :roles, :class_name => "RightOn::Role"'
      Role.module_eval "has_and_belongs_to_many :#{base.table_name}"
    end

    def roles_allowed_to_assign
      Role.accessible_to(self)
    end

    def rights
      @rights ||=
        Right
          .select('distinct rights.*')
          .joins(:roles)
          .where('rights_roles.role_id IN (?)', role_ids)
    end

    def has_access_to?(client_type)
      has_right?(client_type.right)
    end

    def has_right?(right_or_string)
      right = right_or_string.is_a?(Right) ? right_or_string : Right.find_by_name(right_or_string)
      rights.include?(right)
    end

    def has_privileges_of?(other_user)
      (other_user.rights - rights).empty?
    end
  end
end
