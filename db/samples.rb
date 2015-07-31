require 'active_record/fixtures'
require 'fileutils'

puts "adding seed data from fixtures..."

Dir.glob(File.join(Rails.root, "db", "fixtures", "*.csv")).each do |file|
  puts "Adding data from: " + File.basename(file)
  db_args = ['db/fixtures', File.basename(file, '.*')]
  fixture_filename = File.join(*db_args)

  # Throws exception if 'db/fixtures/#{filename}.yml' doesn't yet exist
  FileUtils.touch(fixture_filename)
  ActiveRecord::Fixtures.create_fixtures(*db_args)
end
