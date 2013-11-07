# Created by the Rails 3 jQuery Template
# http://github.com/lleger/Rails-3-jQuery, written by Logan Leger
require 'net/https'
require 'uri'

namespace :jquery do
  desc "Update jQuery and Rails jQuery drivers"
  task :update do
    http = Net::HTTP.new("ajax.googleapis.com",443)
    http.use_ssl = true
    http.start do |http|
        http.use_ssl = true
        resp = http.get("/ajax/libs/jquery/1/jquery.min.js")
        open("public/javascripts/jquery.js", "wb") do |file|
            file.write(resp.body)
        end
    end

    http = Net::HTTP.new("github.com", 443)
    http.use_ssl = true
    http.start do |http|
        http.use_ssl = true
        resp = http.get("/rails/jquery-ujs/raw/master/src/rails.js")
        open("public/javascripts/rails.js", "wb") do |file|
            file.write(resp.body)
        end
    end

    puts "jQuery and Rails jQuery drivers were updated!"
  end
end
