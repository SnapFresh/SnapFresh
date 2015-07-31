require 'csv'

def read_csv(file)
  CSV.read(file, headers: true).map(&:to_hash)
end

def load_sample_data
  file = File.join(Rails.root, "db", "fixtures", "retailers.csv")
  rows = read_csv(file)
  starting_count = Retailer.count
  rows.each.with_index(1) do |row, i|
    print "."
    Retailer.create(row)
  end

  final_count = Retailer.count

  print "\n"
  puts "Rows of data loaded:      #{final_count - starting_count}"
  puts "Total rows of data in db: #{final_count}"
end

load_sample_data
