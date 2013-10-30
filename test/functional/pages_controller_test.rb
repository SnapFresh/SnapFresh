require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test "should GET #about" do
    get :about
    assert_response :success
  end

  test "should GET #terms" do
    get :terms
    assert_response :success
  end

end
