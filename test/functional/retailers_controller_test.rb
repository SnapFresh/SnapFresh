require 'test_helper'

class RetailersControllerTest < ActionController::TestCase

  def setup
    @retailer = retailers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get nearaddy" do
    get :nearaddy, :address => "22314"
    assert_response :success
    assert_not_nil assigns(:retailers)
    # TODO-jw This assertion should be specific
    assert_equal assigns(:retailers).count, 2
  end

### These are general controller tests that need a better home ###
  test "should set translation by locale" do
    %w(en es zh).each do |language|
      get :index, :locale => language
      assert_response :success
      assert locale = language
    end
  end

  test "should set translation by request header" do
    %w(en es zh).each do |language|
      request.env['HTTP_ACCEPT_LANGUAGE'] = language
      get :index
      assert_response :success
      assert locale = language
    end
  end

  test "should set default translation" do
    request.env['HTTP_ACCEPT_LANGUAGE'] = nil
    get :index
    assert_response :success
    assert locale = "en"
  end
##################################################################

end
