require 'test_helper'

class RetailerPresenterTest < ActiveSupport::TestCase

  def setup
    @retailer_presenter = RetailerPresenter.new("22314")
  end

  test "should return retailers" do
    assert_equal @retailer_presenter.retailers, [retailers(:two), retailers(:one)]
  end

  test "should return lat and long" do
    assert_equal @retailer_presenter.origin, [38.7999723, -77.0506896]
  end

  test "should return array of distances from origin" do
    assert_equal @retailer_presenter.distances, [{dist: 5627.86, unit: "mi"}, {dist: 5627.97, unit: "mi"}]
  end

end
