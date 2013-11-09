require 'test_helper'

describe PagesController do

  test "should GET #about" do
    get :about
    assert_response :success
  end

  test "should GET #terms" do
    get :terms
    assert_response :success
  end

  test "should GET #home" do
    get :home
    assert_response :success
  end

end
