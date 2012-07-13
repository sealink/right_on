namespace :rights do
  desc "Check for controllers without rights"
  task :check => :environment do
    puts "Missing rights for controllers:"
    puts RightsManager.missing_rights
  end
  
  desc "Add rights for missing controllers"
  task :add, [:controller, :action] => :environment do |t, args|
    RightsManager.add_right(args)
  end
end
