# Use Yelp API to figure out what kind of establishment each returned retailer is
# Example:
# http://api.yelp.com/business_review_search?term=cream%20puffs&location=650%20Mission%20St%2ASan%20Francisco%2A%20CA&ywsid=XXXXXXXXXXXXXXXX

class Yelp
  attr_reader :retailer

  def initialize(retailer)
    @retailer = retailer
  end

  def business_types
    if result.has_key? 'Error'
      raise "web service error"
    else
     if result["businesses"][0].nil?
       []
     else
       result["businesses"][0]["categories"].map {|c| c["category_filter"]}
     end
    end
  end

  private

  def result
    JSON.parse(get_yelp_data)
  end

  def get_yelp_data
    Net::HTTP.get_response(yelp_uri_object).body
  end

  def yelp_url
    "http://api.yelp.com/business_review_search?term="
  end

  # The below regexp will take off the last word in a store name if it is a number
  # Yelp requires this to do an accurate search
  def sanitized_name
    retailer.name.sub(/\s(#?)\d+\s*$/,'')
  end

  def escaped_name
    URI.escape(sanitized_name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def escaped_location
    "&location=" +
      URI.escape(retailer.street, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) +
      "%2C" + URI.escape(retailer.city, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) +
      "%2C" + URI.escape(retailer.state, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def request
    yelp_url + escaped_name + escaped_location + "&ywsid=VR0eNW8-767FtIrg21dKAA"
  end

  def yelp_uri_object
    URI.parse(request)
  end
end
