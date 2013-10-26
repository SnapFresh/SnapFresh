require 'active_record/fixtures'

puts "adding seed data from fixtures..."

Dir.glob(File.join(Rails.root, "db", "fixtures", "*.csv")).each do |file|
  puts "Adding data from: " + File.basename(file)
  Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
end
