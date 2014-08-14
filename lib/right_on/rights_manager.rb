require 'input_reader'
require 'rails/generators'

# Extra require so generator can be used in rake task
require 'right_on/generators/right_migration_generator'

class RightsManager
  class << self

    def controllers
      controllers_path = File.join("#{Rails.root}",'app','controllers')
      controllers_suffix = '_controller.rb'
      controllers_files = File.join(controllers_path, '**', '*' + controllers_suffix)
      Dir[controllers_files].map do |f|
        [File.dirname(f)[(controllers_path.length + 1)..-1],
          File.basename(f,controllers_suffix)].compact.join('/')
      end
    end


    def missing_rights
      rights = Right.all.map(&:controller)
      controllers.reject { |c| rights.include?(c) }
    end


    def add_right(options = {})
      options = parse_right_options(options)
      add_and_run_right_migration(options)
      add_right_fixture(options)
      puts "Added right #{options[:name]}"
      add_right if options[:unattended].blank? && InputReader.get_boolean(:prompt => "Add another right?(Y/N)")
    end


    def add_right_record(options = {})
      unless Right.find_by_name(options[:name])
        Right.create(options.slice(:controller, :action, :name, :roles))
      end
    end


    # Converts options from {:key => 'value', :key2 => 'value2', :blank => ''}
    # to "--key=value --key2=value2" (Notice how blank is not included)
    def build_unix_options(options = {})
      options.select{|k,v| v.present?}.map do |key, value|
        "--#{key}=#{value}"
      end
    end


    def add_right_migration(options = {})
      migration_options = options.slice(:controller, :action, :right)
      puts options.inspect
      puts "#{options[:name]} #{build_unix_options(migration_options)}"
      migration_file = Rails::Generators.invoke("right_on:right_migration",
        [options[:name]] + build_unix_options(migration_options)
      )
      raise "Could not generate migration" unless migration_file.present?
      migration_file.first
    end


    def add_and_run_right_migration(options = {})
      migration_file = add_right_migration(options)
      ENV['VERSION'] = File.basename(migration_file).split('_').first
      Rake::Task['db:migrate:up'].invoke
      ENV.delete 'VERSION'
      true
    end


    def add_right_fixture(options = {})
      right_roles_yaml_path = File.join("#{Rails.root}",'db','fixtures','rights_roles.yml')
      right_roles = YAML::load_file(right_roles_yaml_path)

      group = options[:group].presence || options[:controller]

      right_roles['rights'][group] ||= []
      right_roles['rights'][group].delete(options[:controller])

      right = right_roles['rights'][group].find do |right|
        right.is_a?(Hash) && right.keys.include?(options[:controller])
      end

      if options[:action].present?
        right ||= (right_roles['rights'][group] << {}).last
        right[options[:controller]] ||= []
        right[options[:controller]] << options[:action] unless right[options[:controller]].include?(options[:action])
      elsif !right
        right_roles['rights'][group] << options[:controller]
      end

      options[:bootstrap_roles].each do |role_title|
        (right_roles['roles'][role_title] || []) << [options[:controller].presence,options[:action].presence].compact.join("#")
      end

      File.open(right_roles_yaml_path, "w") do |f|
        f.write(right_roles.to_yaml)
      end

      true
    end


    private

    def parse_right_options(options = {})
      parsed_options = {}

      parsed_options[:controller] = options[:controller].presence ||
        InputReader.select_item(missing_rights, :prompt => "Right:", :allow_blank => true) ||
        InputReader.get_string(:allow_blank => false, :prompt => "Controller:")

      parsed_options[:action] = options[:action].presence ||
        InputReader.get_string(:allow_blank => true, :prompt => "Action:")

      parsed_options[:name] = options[:name].presence ||
        InputReader.get_string(:allow_blank => true, :prompt => "Name:") ||
        [parsed_options[:controller].presence, parsed_options[:action].presence].compact.join('#')

      parsed_options[:group] = options[:group].presence ||
        InputReader.get_string(:allow_blank => true, :prompt => "Group:")

      parsed_options[:right] = options[:right].presence ||
        InputReader.select_item(Right.all, :selection_attribute => :name, :allow_blank => true, :prompt => "Assign new right to anyone with right:").name

      right_roles_yaml_path = File.join("#{Rails.root}",'db','fixtures','rights_roles.yml')
      right_roles = YAML::load_file(right_roles_yaml_path)
      bootstrap_roles = right_roles['roles'].keys
      parsed_options[:bootstrap_roles] = options[:bootstrap_role].presence ||
        InputReader.select_items(bootstrap_roles, :allow_blank => true, :prompt => "Assign to which bootstrap roles:")

      parsed_options
    end

  end
end
