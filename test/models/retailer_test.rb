require 'test_helper'

describe Retailer do

  before do
    @retailer = retailers(:one)
  end

  test "should return retailer types" do
    VCR.use_cassette('retailer-types') do
      assert_equal(["grocery"], @retailer.retailer_types)
    end
  end

  test "should return distance in miles between a retailer location and a lat and long" do
    @retailer.calculate_distance_from_origin([38.7999723, -77.0506896])
    assert_equal({:dist=>452.98, :unit=>"mi"}, @retailer.distance)
  end

  test "should return 0 distance in feet between a retailer location and a lat and long" do
    @retailer.calculate_distance_from_origin([0.32720379E2, -0.80082291E2])
    assert_equal({:dist=>0, :unit=>"ft"}, @retailer.distance)
  end

  test "should return distance in feet between a retailer location and a lat and long" do
    @retailer.calculate_distance_from_origin([0.3272E2, -0.8008E2])
    assert_equal({:dist=>716, :unit=>"ft"}, @retailer.distance)
  end

  test "should return a retailers address" do
    expect_add = "3603 Maybank Hwy Johns Island SC 29455"
    assert_equal(expect_add, @retailer.address)
  end

  test "should return a googe safe address" do
    url = "http://maps.google.com/maps?q=3603+Maybank+Hwy+Johns+Island+SC+29455"
    assert_equal(url, @retailer.google_safe_address)
  end

  test "should return retailers address without zip" do
    expect_add = "3603 Maybank Hwy Johns Island SC"
    assert_equal(expect_add, @retailer.text_address)
  end  

end
