module RightOn
  module RoleModel
    def self.included(base)
      base.module_eval do
        has_and_belongs_to_many :roles, class_name: 'RightOn::Role'
        has_many :rights, through: :roles, class_name: 'RightOn::Right'
      end
      Role.module_eval do
        has_and_belongs_to_many base.table_name.to_sym, dependent: :restrict
      end
    end

    def has_privileges_of?(other_user)
      (other_user.rights - rights).empty?
    end
  end
end
