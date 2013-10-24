namespace :db do

  desc "drops, creates, migrates, and seeds database"
  task :nuke_pave => :environment do
    unless Rails.env == "Production"
      Rake::Task["db:drop"].execute
      Rake::Task["db:create"].execute
      Rake::Task["db:migrate"].execute
      Rake::Task["db:seed"].execute
      Rake::Task["db:sample"].execute if ["development", "integration"].include?(Rails.env)
    end
  end

  task :sample => :environment do
    load File.join(Rails.root, "db", "samples.rb")
  end

end
