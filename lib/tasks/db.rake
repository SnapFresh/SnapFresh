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

  desc "Deletes, downloads, and reloads all retailer data from USDA"
  task :datarefresh => :environment do
    require 'csv'
    require 'net/http'

    puts "Downloading zip folder"
    Net::HTTP.start("www.snapretailerlocator.com") do |http|
      resp = http.get("/export/Nationwide.zip")
      open("Nationwide.zip", "wb") do |file|
        file.write(resp.body)
      end
    end

    puts "unzip folder and delete"
    system("unzip -o Nationwide.zip -d ./downloads")
    File.delete("Nationwide.zip")

    filepath = Dir.glob("./downloads/*.csv")
    filename = File.basename(filepath[0])

    puts "Deleting all retailers"
    Retailer.delete_all

    puts "Loading retailers"
    i = 0
    CSV.foreach(filename) do |row|
      if ((i % 10000) == 0)
        puts "10K row insertion milestone: " + i.to_s
      end
      cr = Retailer.new
      cr.name = row[0]
      cr.lat = row[2]
      cr.lon = row[1]
      cr.street = row[3]
      # TODO-jw do not skip address #2, append to cr.street
      cr.city = row[5]
      cr.state = row[6]
      cr.zip = row[7]
      cr.zip_plus_four = row[8]
      cr.save
      i += 1
    end

    puts "Delete retailers csv file"
    File.delete("./downloads/" + filename)

    puts "Completed Retailer Data Refresh"
  end

end
