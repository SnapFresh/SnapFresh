namespace :db do

  desc "drops, creates, migrates, and seeds database"
  task :nuke_pave => :environment do
    unless Rails.env == "Production"
      Rake::Task["db:drop"].execute
      Rake::Task["db:create"].execute
      Rake::Task["db:migrate"].execute
      Rake::Task["db:seed"].execute
      if ["development", "integration"].include?(Rails.env)
        Rake::Task["db:sample"].execute
        Rake::Task["db:load_sample_data"].execute
      end
    end
  end

  task :sample => :environment do
    load File.join(Rails.root, "db", "samples.rb")
  end

  task load_sample_data: :environment do
    load File.join(Rails.root, "db", "load_sample_data.rb")
  end

  desc "Deletes retailers, downloads, and reloads all retailers from USDA"
  task :datarefresh => :environment do
    require File.join(Rails.root, "lib", "retailers_importer.rb")
    RetailersImporter.call
  end

end
