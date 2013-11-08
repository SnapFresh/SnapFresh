source 'http://rubygems.org'

gem 'rails', '~> 3.0.7'

# Keep around until RetailersController#get_geo_from_google is removed
gem 'crack', '~> 0.1.8'

# Assets
gem 'sass', '~> 3.2.12'
gem 'jquery-rails', '~> 1.0.2'

# DB's
gem 'pg', '~> 0.17.0'

# Automated cron jobs
gem 'whenever', '~> 0.8.4', :require => false

# Geolocation tools
gem 'geokit', '~> 1.6.7'
gem 'geokit-rails', '~> 2.0.0'

group :test do
  gem "capybara", "~> 2.1.0"
  gem "simplecov", "~> 0.7.1", :require => false
  gem "minitest-spec-rails", "~> 4.7.5"
  gem 'rake'
end

# This group is loaded in test and dev enviroments
# It exists so that Travis-ci doesn't install uncessary gems
group :debug do
  gem "awesome_print", "~> 1.2.0"
  gem "pry", "~> 0.9.12.2"
end
