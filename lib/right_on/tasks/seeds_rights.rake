namespace "db" do
  namespace "seed" do
    desc "Seed initial rights to each role"
    task :rights => :environment do
      load "#{Rails.root}/db/fixtures/rights_roles.rb" 
    end

    namespace "rights" do
      desc "Remove existing rights data and reinitiate it with seeds."
      task :redo => :environment do
        message = []
        message << "This rake task will delete all existing rights and reload Roles with the default rights"
        message << "Every roles will lose their existing rights unless specified in db/fixtures/rights_roles.yml"

        RakeUserInterface.confirmation_required(message) do
          Right.transaction do
            if Right.count > 0
              puts "Removing existing Right data..."
              Right.destroy_all
            end

            Rake::Task["db:seed:rights"].invoke
          end
        end
      end
    end
  end
end
