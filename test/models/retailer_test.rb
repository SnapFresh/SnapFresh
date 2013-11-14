require 'test_helper'

describe Retailer do

  before do
    @retailer = retailers(:one)
  end

  test "should return retailer types" do
    assert_equal @retailer.retailer_types, ["grocery"]
  end

  test "should return distance between a retailer location and a lat and long" do
    @retailer.calculate_distance_from_origin([38.7999723, -77.0506896])
    assert_equal @retailer.distance, {:dist=>452.98, :unit=>"mi"}
  end

  test "should return a googe safe address" do
    assert_equal @retailer.google_safe_address,"http://maps.google.com/maps?q=3603+Maybank+Hwy+Johns+Island+SC+29455"
  end

  test "should return a retailers address" do
    assert_equal @retailer.address, "3603 Maybank Hwy Johns Island SC 29455"
  end

end
