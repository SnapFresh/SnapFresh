source 'http://rubygems.org'

gem 'rails', '~> 3.0.7'

gem 'tropo-webapi-ruby', '~> 0.1.10'
gem 'crack', '~> 0.1.8'
gem 'geokit', '~> 1.5.0'
gem 'geokit-rails', '~> 1.1.4'
gem 'will_paginate', '~> 3.0.pre2'
gem 'whenever', '~> 0.8.4', :require => false
gem "geocoder", "~> 1.1.8"

# Assets
gem 'haml', '~> 3.1.1'
gem 'sass', '~> 3.1.1'
gem 'jquery-rails', '~> 1.0.2'

# DB's
gem 'pg', '~> 0.13.2'

group :test do
  gem "capybara", "~> 2.1.0"
  gem "simplecov", "~> 0.7.1", :require => false
  gem "minitest-spec-rails", "~> 4.7.4"
  gem 'rake'
end

# This group is loaded in test and dev enviroments
# It exists so that Travis-ci doesn't install uncessary gems
group :debug do
  gem "awesome_print", "~> 1.1.0"
  gem "pry", "~> 0.9.12.2"
end
