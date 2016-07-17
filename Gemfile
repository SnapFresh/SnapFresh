source 'http://rubygems.org'

ruby "1.9.3"
gem 'rails', '~> 4.2.3'

gem "jbuilder", "~> 1.5.2"
# Keep around until RetailersController#get_geo_from_google is removed
gem 'crack', '~> 0.4.1'
# Temporary measure for handling ENV due to not having control over deploy process.
gem 'figaro'
gem 'geokit', '~> 1.6.7'
gem 'geokit-rails', '~> 2.0.0'
gem 'jquery-rails', '~> 3.0.4'
gem 'pg', '~> 0.18.2'
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '~> 2.3.1'
gem 'whenever', '~> 0.8.4', :require => false

# This group is loaded in test and dev enviroments
# It exists so that Travis-ci doesn't install uncessary gems
group :debug do
  gem "annotate", "~> 2.5.0"
  gem "awesome_print", "~> 1.2.0"
  gem "pry", "~> 0.9.12"
end

group :doc do
  gem 'sdoc', require: false
end

group :test do
  gem "capybara", "~> 2.1.0"
  gem "simplecov", "~> 0.8.1", :require => false
  gem 'json_expressions', '~> 0.8.3'
  gem 'minitest-spec-rails', '~> 5.2.2'
  gem 'rake'
  gem 'vcr'
  gem 'webmock'
end
