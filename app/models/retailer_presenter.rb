class RetailerPresenter
  attr_reader :origin

  def initialize(address)
    @origin = retrieve_lat_long(address)
    calculate_distances_from_origin(origin)
  end

  def retailers
    @retailers ||= Retailer.by_distance(origin: origin).limit(5)
  end

  def to_text
    retailers.each_with_index.map do |retailer, index|
      "#{index + 1} (#{retailer.distance[:dist]} #{retailer.distance[:unit]}): #{retailer.name}\n#{retailer.text_address}"
    end.join("\n\n")
  end

  private

  def calculate_distances_from_origin(lat_long)
    retailers.each do |retailer|
      retailer.calculate_distance_from_origin(lat_long)
    end
  end

  def retrieve_lat_long(address)
    Geokit::Geocoders::GoogleGeocoder3.geocode(address).ll.split(',').collect{ |i| i.to_f }
  end

end
