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
  end

  # GET /retailers/near/:lat/:lon
  def near_geo
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
  
  # GET /retailers/nearaddy/:address
  def nearaddy
    usergeo = get_geo_from_google(params[:address])
    origin = [usergeo[:lat], usergeo[:long]]
    @retailers = Retailer.find :all,
                              :origin => origin,
                              :order => 'distance',
                              :limit => 5
    @count = 1
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailers}
      format.text { render :text => @retailers.to_enum(:each_with_index).map{|r, i| r.name = "#{i+1}: #{r.name}\n#{r.text_address}"}.join("\n\n")}
    end
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


  private
    def sort_column
      Retailer.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end

