module RightOn
  module Generators
    class RightMigrationGenerator < Rails::Generators::Base
      
      include Rails::Generators::Migration
      
      source_root File.expand_path('../templates', __FILE__)
      
      argument :name, :type => :string, :required => false
      
      class_option :controller, :type => :string, :required => false, 
        :desc => "Indicates the right's controller"
      class_option :action,     :type => :string, :required => false, 
        :desc => "Indicates the right's action"
      class_option :roles,      :type => :array,  :required => false, 
        :desc => "Indicates the roles to which the right should be granted", 
        :banner => "role_1 role_2 role_3"
      
      
      def generate_migration
        raise MissingArgument, "Either name or controller must be specified" if right_controller.blank?
        migration_template "right_migration.rb", "db/migrate/add_#{parsed_right_name}_right.rb"
      end
      
      
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end
      
      private
         
      def right_controller
        (options[:controller] || name.to_s.split('#')[0]).to_s.underscore.presence
      end
      
      
      def right_action
        (options[:action] || name.to_s.split('#')[1]).to_s.underscore.presence
      end
      
      
      def right_name
        name.presence || [right_controller, right_action].compact.join('#')
      end
      
      
      def right_roles
        Array.wrap(options[:roles])
      end
      
      
      def parsed_right_name
        right_name.gsub('/','_').gsub('#','_').underscore
      end
      
    end
  end
end
