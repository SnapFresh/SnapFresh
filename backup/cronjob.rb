#!/usr/bin/env ruby
require 'net/http'




Net::HTTP.start("www.snapretailerlocator.com") do |http|
  states = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN",
            "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA",
            "WI", "WV", "WY"]

  # Pull in all the state ZIP files containing the CSV files
  states.each  do |state|
    resp = http.get("/export/" + state + ".zip")
    open(state + ".zip", "wb") do |file|
      file.write(resp.body)   
    end
    system("unzip -o #{state}.zip")
    File.delete(state + ".zip")
  end
  # Unzip all of the ZIP files
end
puts "Done Importing & Unzipping!"

File.open("fixtures/retailers.csv","w") do |outfile|
  # insert col names as first line
  outfile.syswrite('"name","lon","lat","street","city","state","zip","zip_plus_four"'+"\n")
  (Dir.glob("*.csv") - ["retailers.csv"]).each do |csv_file|
    File.open(csv_file) do |infile|
      infile.readline #skip the first line
      outfile << infile.read
    end
    File.delete(csv_file)
  end
end


