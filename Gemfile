source 'http://rubygems.org'
ruby "1.9.3"

gem 'rails', '~> 4.0.1'

# DB's
gem 'pg', '~> 0.17.0'

# Assets
gem 'sass-rails', '~> 4.0.1'
gem 'jquery-rails', '~> 3.0.4'
gem 'jquery_mobile_rails', '~> 1.3.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.3.1'

# Keep around until RetailersController#get_geo_from_google is removed
gem 'crack', '~> 0.4.1'

# Automated cron jobs
gem 'whenever', '~> 0.8.4', :require => false

# Geolocation tools
gem 'geokit', '~> 1.6.7'
gem 'geokit-rails', '~> 2.0.0'

# Performance measuring
# gem 'rack-mini-profiler', '~> 0.1.31'

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
  gem "annotate", "~> 2.5.0"
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
