require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  setup do
    @request = requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request" do
    assert_difference('Request.count') do
      post :create, :request => @request.attributes
    end

    assert_redirected_to request_path(assigns(:request))
  end

  test "should show request" do
    get :show, :id => @request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @request.to_param
    assert_response :success
  end

  test "should update request" do
    put :update, :id => @request.to_param, :request => @request.attributes
    assert_redirected_to request_path(assigns(:request))
  end

  test "should destroy request" do
    assert_difference('Request.count', -1) do
      delete :destroy, :id => @request.to_param
    end

    assert_redirected_to requests_path
  end
end
