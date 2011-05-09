class Retailer < ActiveRecord::Base
    acts_as_mappable :lng_column_name => :lon
end
