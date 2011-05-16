class RetailersController < ApplicationController
  # GET /retailers
  # GET /retailers.xml
  helper_method :sort_column, :sort_direction

  def index

  end

  def browse 
    @retailers = Retailer.search(params[:search]).order( sort_column + " " + sort_direction).paginate(:page => params[:page])

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.xml  { render :xml => @retailers }
    #end
  end
  
  def list
    @latlon = get_geo_from_google(params[:address])
    @lat = @latlon[:lat]
    @lon = @latlon[:lon]
    
    redirect_to :controller => 'retailers', :action => 'near', :params => 
                                                                params[ :lat => @lat, :lon => @lon ]
    #@lat = @latlon.first[:lat]
    #@lon = @latlon.first[:lon]
    #@latlon = "Blah"
  end

  # GET /retailers/near/:lat/:lon
  def near
    origin = [params[:lat],params[:lon]]
    @retailers = Retailer.find :all,
                              :origin => origin,
                              #:within => 5,
                              :order => 'distance',
                              :limit => 5
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailer }
      format.json { render :json => @retailer }
    end
  end
  
  # GET /retailers/nearaddy/:street/:city/:state
  def nearaddy
    # geocode the address using USC database
    #usergeo = get_geo_and_zip_from_address(URI.escape(params[:street], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),URI.escape(params[:city], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(params[:state], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")));
    usergeo = get_geo_from_google(params[:address])
    origin = [usergeo[:lat], usergeo[:long]]
    @retailers = Retailer.find :all,
                              :origin => origin,
                              :order => 'distance',
                              :limit => 5
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  def get_geo_from_google(address)
   geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="
    output = "&sensor=false"
    #address = "424+ellis+st+san+francisco"
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
  
  def get_geo_and_zip_from_address(address)
    #using a free USC geocoder (limit 2500 hits before you need to register)
    geocoder = "http://webgis.usc.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsed_V02_95.aspx?apiKey=a8dbf3d653e345b8b67792e55b263d15&&format=XML&census=false&notStore=false&version=2.95&verbose=true&"
    #staddress= "streetAddress=" + staddress;
    #stcity = "&city=" + stcity;
    #st = "&state="+ st;   
    address_string = "address=" + address.tr(' ', '+')
    request = geocoder + address_string
    url = URI.parse(request)
    resp = Net::HTTP.get_response(url)
    array = []
    #parse result if result received properly
    if resp.is_a?(Net::HTTPSuccess)
      #puts("Got here \n")
       #parse the XML
      parse = Nokogiri::XML(resp.body)
      status = parse.xpath("//QueryStatusCodeValue").text;
      # puts(status)
       #check if request went well
       if status == "200"
        # return zip and lat long if request successful
          lat = parse.xpath("//OutputGeocode//Latitude").text;
          long = parse.xpath("//OutputGeocode/Longitude").text;
          zip = parse.xpath("//ReferenceFeature/Zip").text;
       # puts("lat: " + lat + " long: " + long + " zip: " + zip + "\n")
           infohash = { 'lat' => lat, 'long' => long, 'zip' => zip  }
         end
         # puts("infohash: " + infohash["zip"]);    
         return infohash
       end
   end


  # GET /retailers/1
  # GET /retailers/1.xml
  def show
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  # GET /retailers/new
  # GET /retailers/new.xml
  def new
    @retailer = Retailer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  # GET /retailers/1/edit
  def edit
    @retailer = Retailer.find(params[:id])
  end

  # POST /retailers
  # POST /retailers.xml
  def create
    @retailer = Retailer.new(params[:retailer])

    respond_to do |format|
      if @retailer.save
        format.html { redirect_to(@retailer, :notice => 'Retailer was successfully created.') }
        format.xml  { render :xml => @retailer, :status => :created, :location => @retailer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retailer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retailers/1
  # PUT /retailers/1.xml
  def update
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      if @retailer.update_attributes(params[:retailer])
        format.html { redirect_to(@retailer, :notice => 'Retailer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retailer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retailers/1
  # DELETE /retailers/1.xml
  def destroy
    @retailer = Retailer.find(params[:id])
    @retailer.destroy

    respond_to do |format|
      format.html { redirect_to(retailers_url) }
      format.xml  { head :ok }
    end
  end

  private
    def sort_column
      Retailer.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def lat
      params[:lat] ? params[:lat] : "lat"
    end

    def lon
      params[:lon] ? params[:lon] : "lon"
    end

end

