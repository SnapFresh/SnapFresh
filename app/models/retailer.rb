# == Schema Information
#
# Table name: retailers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  lat           :decimal(, )
#  lon           :decimal(, )
#  street        :string(255)
#  city          :string(255)
#  state         :string(255)
#  zip           :string(255)
#  zip_plus_four :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'cgi'

class Retailer < ActiveRecord::Base
  acts_as_mappable :lng_column_name => :lon
  attr_accessor :distance

  def retailer_types
    Yelp.new(self).business_types
  end

  def distance_from_origin(orig)
    #passed the origin array from the retailers controller
    lat1 = orig[0]
    long1 = orig[1]
    lat2 = self.lat
    long2 = self.lon
    radiansperdegree = 3.14159265359 / 180
    lonsrad = (long2 - long1) * radiansperdegree
    latsrad = (lat2 - lat1) * radiansperdegree
    lat1rad = lat1 * radiansperdegree
    lat2rad = lat2 * radiansperdegree
    a = (Math.sin(latsrad/2))**2 + Math.cos(lat1rad) * Math.cos(lat2rad) * (Math.sin(lonsrad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    # assuming the great circle radius is 6371 km = abt 3958 miles
    dist = 3958 * c
    # list feet if under 1 mile. And miles to 2 decimal places if over 1 mile
    if dist < 1
      dist = dist * 5280
      self.distance = { :dist => dist.round.to_i, :unit => "ft" }
    else
      self.distance = { :dist => dist.round(2), :unit => "mi" }
    end
  end

  def address
    [self.street, self.city, self.state, self.zip].join(" ")
  end

  def google_safe_address
    "http://maps.google.com/maps?q=" + CGI::escape(address)
  end

  ## TODO Are these used? ##
  def text_address
    [self.street, self.city, self.state].join(" ")
  end

  # MMK added this 1/27/2012 due to null "type" errors from XML rendering
  # See: http://stackoverflow.com/questions/6808958/to-xml-doesnt-work-on-objects-returned-through-rails-activerecord-habtm-referen
  def to_xml(options = {})
    to_xml_opts = {:skip_types => true} # no type information, not such a great idea!
    to_xml_opts.merge!(options.slice(:builder, :skip_instruct))
    # a builder instance is provided when to_xml is called on a collection,
    # in which case you would not want to have <?xml ...?> added to each item
    to_xml_opts[:root] ||= "retailer"
    self.attributes.to_xml(to_xml_opts)
  end
end
