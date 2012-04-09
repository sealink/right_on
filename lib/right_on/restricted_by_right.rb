module RestrictedByRight

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def restricted_by_right(options = {})
      options ||= {}
      options[:group] ||= 'other'
      Right.associate_group(self, options[:group])

      class << self
        def accessible_to(user)
          all.select{|o| user.rights.include?(o.right)}
        end
      end

      include InstanceMethods

      belongs_to :right
      before_create :create_access_right!
      after_destroy :destroy_access_right!
    end

  end

  module InstanceMethods

    private

      def create_access_right!
        self.right = Right.find_or_create_by_name(:name => "#{self.class.name.titleize}: #{name}")
      end

      def destroy_access_right!
        self.right.try(:destroy)
      end

  end

end

