class RetailerPresenter
  attr_accessor :origin, :distances

  def initialize(address)
    @origin = retrieve_lat_long(address)
    @distances = distance_from_origin(origin)
  end

  def retailers
    @retailers ||= Retailer.find( :all, origin: origin, order: 'distance', limit: 5)
  end

  private

  def distance_from_origin(lat_long)
    dists = []
    retailers.each do |retailer|
      dists << retailer.distance_from_origin(lat_long)
    end
    return dists
  end

  def retrieve_lat_long(address)
    Geocoder.search(address).first.coordinates
  end

end
