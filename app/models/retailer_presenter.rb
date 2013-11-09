class RetailerPresenter
  attr_reader :origin

  def initialize(address)
    @origin = retrieve_lat_long(address)
    calculate_distances_from_origin(origin)
  end

  def retailers
    @retailers ||= Retailer.by_distance(origin: origin).limit(5)
  end

  def as_json(options = {})
    { origin: origin, retailers: retailers.as_json(methods: :distance, except: [:id, :created_at, :updated_at]) }
  end

  private

  def calculate_distances_from_origin(lat_long)
    retailers.each do |retailer|
      retailer.distance_from_origin(lat_long)
    end
  end

  def retrieve_lat_long(address)
    Geokit::Geocoders::GoogleGeocoder3.geocode(address).ll.split(',').collect{ |i| i.to_f }
  end

end
