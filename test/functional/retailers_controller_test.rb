require 'test_helper'

class RetailersControllerTest < ActionController::TestCase

  def setup
    @retailer = retailers(:one)
  end

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

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get aboutus" do
    get :aboutus
    assert_response :success
  end

  test "should get terms" do
    get :terms
    assert_response :success
    assert_not_nil assigns(:terms)
  end

  test "should get browse" do
    get :browse
    assert_response :success
    # TODO test that the correct list of retailers is being returned
    assert_not_nil assigns(:retailers)
  end

  test "should get nearaddy" do
    get :nearaddy, :address => "22314"
    assert_response :success
    # TODO This assertion should be more specific
    assert_equal Retailer.all, assigns(:retailers)
  end

  # TODO is :show being used for anything?
  # test "should show retailer" do
  #   get :show, :id => @retailer.id
  #   assert_response :success
  #   assert_equal retailers(:one), assigns(:retailer)
  # end

  # TODO Is :list being used by anyting? It's not being used by rails
  # Perhaps the iOS app?
  # test "should get list" do
  #   get :list
  #   # TODO These tests should assert there is correct lat/long
  #   assert_not_nil assigns(:latlon)
  #   assert_not_nil assigns(:lat)
  #   assert_not_nil assigns(:long)
  #   # TODO this should be passing lat/long from params
  #   assert_redirected_to near_retailers_path
  # end

  # TODO How is this being used?
  # test "should get neargeo" do
  # end

end
