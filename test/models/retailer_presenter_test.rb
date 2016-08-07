require 'test_helper'

describe RetailerPresenter do

  before do
    @address = "22314"
    VCR.use_cassette('retailer-presenter-before') do
      @retailer_presenter = RetailerPresenter.new(@address)
    end
  end

  test "should return retailers" do
    assert_equal @retailer_presenter.retailers, [retailers(:one), retailers(:two)]
  end


  test "GoogleGeocoder should return correct lat and long" do
    VCR.use_cassette('retailer-presenter-google') do
      assert_equal @retailer_presenter.send(:retrieve_lat_long, @address), [38.7999723, -77.0506896]
    end
  end

  test "should return lat and long" do
    assert_equal @retailer_presenter.origin, [38.7999723, -77.0506896]
  end

  test "retailer should have a distance" do
    assert_equal @retailer_presenter.retailers.map(&:distance), [{:dist=>452.98, :unit=>"mi"}, {:dist=>5627.86, :unit=>"mi"}]
  end

  test "should convert retailer to txt message format" do
    expect_text = ["1 (452.98 mi): CIRCLE K STORE 8103",
                  "3603 Maybank Hwy Johns Island SC\n",
                  "2 (5627.86 mi): Two Local Mart",
                  "Two Street Two Town VA"].join("\n")
    assert_equal @retailer_presenter.to_text, expect_text
  end

end
