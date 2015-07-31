require 'test_helper'

describe Yelp do

  before do
    @yelp = Yelp.new(retailers(:one))
  end

  test "should return business types" do
    VCR.use_cassette('yelp-business-types') do
      assert_equal @yelp.business_types, ["grocery"]
    end
  end

end
