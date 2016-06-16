module RightOn
  module RestrictedByRight

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def restricted_by_right(options = {})
        options ||= {}
        group = options.fetch(:group, 'other')

        @right_on_config ||= {}
        @right_on_config[:restricted_by_right_group] = group

        Right.associate_group(self, group)

        class << self
          def accessible_to(user)
            all.select{|o| user.rights.include?(o.right)}
          end
        end

        include InstanceMethods

        belongs_to :right, :class_name => 'RightOn::Right'
        before_create :create_access_right!
        after_destroy :destroy_access_right!
      end

      def restricted_by_right_group
        (@right_on_config || {})[:restricted_by_right_group]
      end
    end

    module InstanceMethods

      private

        def create_access_right!
          right_name = "#{self.class.name.titleize}: #{name}"
          self.right = find_right(right_name) || Right.create!(:name => right_name)
        end

        def find_right(name)
          Right.find_by(:name => name)
        end

        def destroy_access_right!
          self.right.try(:destroy)
        end

    end

  end
end
