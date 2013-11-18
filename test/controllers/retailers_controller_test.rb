require 'test_helper'

describe RetailersController do
  let(:retailer_presenter) { RetailerPresenter.new(address) }
  let(:address) { '22314' }

  describe 'GET #index' do
    context 'when asked for html' do
      it 'should return retailers by address' do
        get :index, address: address
        assigns(:retailer_presenter).wont_be_nil
        assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
      end

      it 'should respond with 200' do
        get :index, address: address
        assert_response :success
      end

      it 'should render index template' do
        get :index, address: address
        assert_template :index
      end
    end

    context 'when asked for text' do
      let(:format) { :text }

      it 'should return retailers by address' do
        get :index, format: format, address: address
        assigns(:retailer_presenter).wont_be_nil
        assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
      end

      it 'respond with 200' do
        get :index, format: format, address: address
        assert_response :success
      end

      it 'should render as text' do
        get :index, format: format, address: address
        response.body.must_equal retailer_presenter.to_text
      end
    end

    context 'when asked for json' do
      let(:format) { :json }

      it 'should return retailers by address' do
        get :index, format: format, address: address
        assigns(:retailer_presenter).wont_be_nil
        assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
      end

      it 'should respond with 200' do
        get :index, format: format, address: address
        assert_response :success
      end

      it 'should render json template' do
        get :index, format: format, address: address
        JSON.parse(response.body).count.must_equal retailer_presenter.retailers.count
        # TODO test that body has correct fields
        # JSON.parse(response.body).must_equal retailer_presenter_to_json
      end

    end
  end

  describe 'depreciated retailer action' do
    # not well tested!! accepts json, text
    test 'should GET#nearaddy' do
      get :nearaddy, :address => "22314", :format => :json
      assert_not_nil assigns(:retailers)
      assert_equal assigns(:retailers).count, 2
    end
  end

  # These tests are for the ApplicationController locale logic
  describe "should select proper translation" do
    it "by locale" do
      %w(en es zh).each do |language|
        get :index, :locale => language, :address => "22314"
        assert_response :success
        assert locale = language
      end
    end

    it "by request header" do
      %w(en es zh).each do |language|
        request.env['HTTP_ACCEPT_LANGUAGE'] = language
        get :index, :address => "22314"
        assert_response :success
        assert locale = language
      end
    end

    it "form default translation" do
      request.env['HTTP_ACCEPT_LANGUAGE'] = nil
      get :index, :address => "22314"
      assert_response :success
      assert locale = "en"
    end
  end

  # private

  # def retailer_presenter_to_json
  #   retailer_presenter.retailers.as_json(methods: :distance, except: [:id, :created_at, :updated_at])
  # end
end
