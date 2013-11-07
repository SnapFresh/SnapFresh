class RetailersController < ApplicationController

  # GET /retailers
  # GET /retailers.json
  def index
    @retailer_presenter = RetailerPresenter.new(params[:address])
    # TODO Count is used in the internationalization content, learn why it is setup this way
    @count = 1
    respond_to do |format|
      format.html
      format.json do
        render json: { origin: @retailer_presenter.origin, retailers: @retailer_presenter.retailers }
      end
    end
  end

  # Everything below this point is considered depreciated
  # It hasn't been removed because iOS applications and Tropo still use this API

  # GET /retailers/nearaddy/:address
  def nearaddy
    usergeo = get_geo_from_google(params[:address])
    origin = [usergeo[:lat], usergeo[:long]]
    @retailers = Retailer.find :all,
                              :origin => origin,
                              :order => 'distance',
                              :limit => 5
    @count = 1
    # populates the instance variable rt array of hashes with the distance and unit for each retailer returned in the retailer collection
    @rt = Array.new
    @retailers.each_with_index do |r, ind|
      @rt[ind] = { :dist => r.distance_from_origin(origin)[:dist], :unit => r.distance_from_origin(origin)[:unit] }
    end
    respond_to do |format|
      format.xml  { render :xml => @retailers }
      format.json { render :json => { :origin => origin, :retailers => @retailers } }
      format.text { render :text => @retailers.to_enum(:each_with_index).map{|r, i| r.name = "#{i+1} (#{@rt[i][:dist]} #{@rt[i][:unit]}): #{r.name}\n#{r.text_address}"}.join("\n\n")}
    end
  end

  private

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
