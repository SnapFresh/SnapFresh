require 'test_helper'

class RetailersControllerTest < ActionController::TestCase

  setup do
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

  # test "should get index" do
  #   get :index
  #   assert_response :success
  # end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should show retailer" do
  #   get :show, :id => @retailer.to_param
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, :id => @retailer.to_param
  #   assert_response :success
  # end

  # test "should get aboutus" do
  #   get :aboutus
  # end

  # test "should get terms" do
  #   get :terms
  #   assert_response :success
  #   assert_not_nil assigns(:terms)
  # end

  # browse
  # list
  # neargeo
  # nearaddy
  # get_geo_from_goole

end
