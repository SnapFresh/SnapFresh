class RetailerPresenter
  attr_accessor :origin, :distances

  def initialize(address)
    @origin = retrieve_users_lat_long(address)
    @distances = distance_from_origin
  end

  def retailers
    @retailers ||= Retailer.find( :all, origin: origin, order: 'distance', limit: 5)
  end

  private

  def distance_from_origin
    dists = []
    retailers.each do |retailer|
      dists << retailer.distance_from_origin(origin)
    end
  end

  def retrieve_users_lat_long(address)
    @lat_long ||= Geocoder.search(address)[0].coordinates
  end

end
