module RequestsHelper
  def get_address_from_zip (address)
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="
    output = "&sensor=false"
    #address = "424+ellis+st+san+francisco"
    request = geocoder + address + output
    url = URI.escape(request)
    resp = Net::HTTP.get_response(URI.parse(url))
    #parse result if result received properly
    if resp.is_a?(Net::HTTPSuccess)
      #parse the json
      parse = Crack::JSON.parse(resp.body)
      #check if google went well
      if parse["status"] == "OK"
       # return parse if raw == true
        array = []
        parse["results"].each do |result|
          array <<{
            :lat => result["geometry"]["location"]["lat"],
            :long => result["geometry"]["location"]["lng"],
            :matched_address => result["formatted_address"],
            :bounds => result["geometry"]["bounds"],
            :zip => result["geometry"]["bounds"]  
          }
        end
        zip = address[-5,4]+"%"
        #SELECT city, street, name, AVG(3956 * 2 * ASIN(SQRT(POWER(SIN((37.4404 - abs(`lat`)) * pi()/180 / 2),2) + COS(37.4404 * pi()/180 ) * COS(abs(`lat`) * pi()/180) * POWER(SIN((-121.8705 - `long`) * pi()/180 / 2), 2) ))) AS distance
        #@retailer = Retailer.find_by_sql("SELECT name, street, city, state, zip FROM retailers WHERE zip like '9410%'")      
        @retailer = Retailer.find_by_sql("SELECT name, street, city, state, zip FROM retailers WHERE zip like \"#{zip}\"")      
        #return parse
        return @retailer.to_s
        #return zip
      end
    end

    return parse
  end

end
