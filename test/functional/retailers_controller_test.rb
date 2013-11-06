require 'test_helper'

class RetailersControllerTest < ActionController::TestCase

  def setup
    @retailer = retailers(:one)
  end

  test "should get index" do
    get :index, :address => "22314"
    assert_response :success
    assert_not_nil assigns(:retailer_presenter)
    # TODO This assertion should be specific
    assert_equal assigns(:retailer_presenter).retailers.count, 2
  end

  # Depreciated; however, do not remove. Still in use by iOS application.
  test "should get nearaddy" do
    get :nearaddy, :address => "22314"
    assert_response :success
    assert_not_nil assigns(:retailers)
    assert_equal assigns(:retailers).count, 2
  end

### These are general controller tests that need a better home ###
  test "should set translation by locale" do
    %w(en es zh).each do |language|
      get :index, :locale => language, :address => "22314"
      assert_response :success
      assert locale = language
    end
  end

  test "should set translation by request header" do
    %w(en es zh).each do |language|
      request.env['HTTP_ACCEPT_LANGUAGE'] = language
      get :index, :address => "22314"
      assert_response :success
      assert locale = language
    end
  end

  test "should set default translation" do
    request.env['HTTP_ACCEPT_LANGUAGE'] = nil
    get :index, :address => "22314"
    assert_response :success
    assert locale = "en"
  end
##################################################################

end
