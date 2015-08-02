require 'active_record/fixtures'
require 'fileutils'

puts "adding seed data from fixtures..."

Dir.glob(File.join(Rails.root, "db", "fixtures", "*.csv")).each do |file|
  puts "Adding data from: " + File.basename(file)
  db_args = ['db/fixtures', File.basename(file, '.*')]
  fixture_filename = File.join(*db_args)

  # Throws exception if 'db/fixtures/#{filename}.yml' doesn't yet exist
  fixtures = File.join('db/fixtures', "#{File.basename(file, '.*')}.yml")
  FileUtils.touch(fixtures)
  ActiveRecord::Fixtures.create_fixtures(*db_args)
  # Now that ActiveRecord::Fixtures is happy, let's remove the file
  FileUtils.rm(fixtures, force: true)
end
