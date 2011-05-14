class Retailer < ActiveRecord::Base
    acts_as_mappable :lng_column_name => :lon

    def self.search(search)
      if search
        where('name LIKE ?', "%#{search}%")
      else
        scoped
      end
    end
end
