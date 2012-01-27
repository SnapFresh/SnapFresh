class Retailer < ActiveRecord::Base
    require 'cgi'
    acts_as_mappable :lng_column_name => :lon
    
    def retailer_types
      # Use Yelp API to figure out what kind of establishment each returned retailer is
      yelpurl = "http://api.yelp.com/business_review_search?term="
      # The below regexp will take off the last word in a store name if it is a number
      # Yelp requires this to do an accurate search
      escfir = self.name.sub(/\s(#?)\d+\s*$/,'')
      escname =  URI.escape(escfir, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      esclocation = "&location=" + URI.escape(self.street, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) + "%2C" +
        URI.escape(self.city, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) + "%2C" + URI.escape(self.state, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      request = yelpurl + escname + esclocation + "&ywsid=VR0eNW8-767FtIrg21dKAA"
      puts request
      #http://api.yelp.com/business_review_search?term=cream%20puffs&location=650%20Mission%20St%2ASan%20Francisco%2A%20CA&ywsid=XXXXXXXXXXXXXXXX
      url = URI.parse(request)
      yelpdata = Net::HTTP.get_response(url)    
      # yelpdata.body is a json file
      # Now parse the JSON for the retailer type - i.e. "Categories"
      data = yelpdata.body
      # we convert the returned JSON data to native Ruby
      # data structure - a hash
      result = JSON.parse(data)
      # if the hash has 'Error' as a key, we raise an error
       if result.has_key? 'Error'
        raise "web service error"
       end
      if result["businesses"][0].nil?
        return []
      else return result["businesses"][0]["categories"].map {|c| c["category_filter"]}
      end
    end
    
    def address
      [self.street, self.city, self.state, self.zip].join(" ")
    end
    
    # MMK added this 1/27/2012 due to null "type" errors from XML rendering
    # See: http://stackoverflow.com/questions/6808958/to-xml-doesnt-work-on-objects-returned-through-rails-activerecord-habtm-referen
    def to_xml(options = {})
        to_xml_opts = {:skip_types => true} # no type information, not such a great idea!
        to_xml_opts.merge!(options.slice(:builder, :skip_instruct))
        # a builder instance is provided when to_xml is called on a collection,
        # in which case you would not want to have <?xml ...?> added to each item
        to_xml_opts[:root] ||= "retailer"
        self.attributes.to_xml(to_xml_opts)
    end
    
    def text_address
      [self.street, self.city, self.state].join(" ")
    end

    def google_safe_address
      CGI::escape(address)
    end

    def self.search(search)
      if search
        where('name ILIKE ?', "%#{search}%")
      else
        scoped
      end
    end
end
