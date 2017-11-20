module RightOn
  module RoleModel
    def self.included(base)
      base.module_eval 'has_and_belongs_to_many :roles, :class_name => "RightOn::Role"'
      Role.module_eval "has_and_belongs_to_many :#{base.table_name}, dependent: :restrict"
    end

    def rights
      @rights ||=
        Right
          .select('distinct rights.*')
          .joins(:roles)
          .where('rights_roles.role_id IN (?)', role_ids)
    end

    def has_privileges_of?(other_user)
      (other_user.rights - rights).empty?
    end
  end
end
