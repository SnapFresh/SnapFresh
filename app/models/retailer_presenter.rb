class RetailerPresenter
  attr_accessor :origin, :rt

  def initialize(address)
    @origin = get_origin(address)
    @rt = []
    distance_from_origin
  end

  def retailers
    @retailers ||= Retailer.find( :all, origin: origin, order: 'distance', limit: 5)
  end

  private

  def distance_from_origin
    retailers.each_with_index do |r, ind|
      rt[ind] = { dist: r.distancefromorigin(origin)[:dist], :unit => r.distancefromorigin(origin)[:unit] }
    end
  end

  def get_origin(address)
    # gets lat and long for address
    usergeo ||= get_geo_from_google(address)
    # creates array of lat and long
    [usergeo[:lat], usergeo[:long]]
  end

  def get_geo_from_google(address)
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="
    output = "&sensor=false"
    #address = "424+ellis+st+san+francisco"
    # replace any ampersands with "and" since ampersands don't seem to work with the google query
    address =  address.sub( "&", "and" )
    request = geocoder + address.tr(' ', '+') + output
    url = URI.escape(request)
    resp = Net::HTTP.get_response(URI.parse(url))
    #parse result if result received properly
    if resp.is_a?(Net::HTTPSuccess)
      #parse the json
      parse = Crack::JSON.parse(resp.body)
      #check if google went well
      if parse["status"] == "OK"
       # return parse if raw == true
        parse["results"].each do |result|
          geo_hash = {  :lat => result["geometry"]["location"]["lat"],
                        :long => result["geometry"]["location"]["lng"]
          }
          return geo_hash
        end
     end
    end

    return parse
  end
end
