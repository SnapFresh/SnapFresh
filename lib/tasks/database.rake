require 'csv'
require 'net/http'
require 'rake'

namespace :db do
    desc "Custom Rake task to remap data"
    task :datarefresh => :environment do
        # Download the CSV file:
        Net::HTTP.start("www.snapretailerlocator.com") do |http|
            resp = http.get("/export/Nationwide.zip")
            open("Nationwide.zip", "wb") do |file|
                file.write(resp.body)
            end
        end
        system("unzip -o Nationwide.zip")
        File.delete("Nationwide.zip")
        # Delete out all the current retailers
        Retailer.delete_all
        # need a way to get the filename when we don't know what it is (date stamped)
        i = 0
        CSV.foreach ('store_locations_2012_11_08.csv') do |row|
            next if row[0] == "Store_Name"
            if ((i % 10000) == 0)
                puts "10K row insertion milestone: " + i.to_s
            end
            cr = Retailer.new
            cr.name = row[0]
            cr.lat = row[2]
            cr.lon = row[1]
            cr.street = row[3]
            cr.city = row[5]
            cr.state = row[6]
            cr.zip = row[7]
            cr.zip_plus_four = row[8]
            cr.save
	    i = i +1
        end
    end
end
