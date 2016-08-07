require 'test_helper'
require 'capybara/rails'

class AddressSearchTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should return retailers by zipcode" do
    VCR.use_cassette('address-search-test-by-zipcode') do
      visit '/'
      fill_in('address', with: '22314')
      find('.submit').click
      assert_selector('main ul li', count: 2)
    end
  end

  test "should return retailers by street address" do
    VCR.use_cassette('address-search-by-street-address') do
      visit '/'
      fill_in('address', with: '601 Jefferson Street, Alexandria, VA')
      find('.submit').click
      assert_selector('main ul li', count: 2)
    end
  end

end
