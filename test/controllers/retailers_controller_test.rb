require 'test_helper'

describe RetailersController do
  let(:retailer_presenter) { RetailerPresenter.new(address) }
  let(:address) { '22314' }
  let(:json_pattern) do
    {
      origin: Array,
      retailers: [
        retailer: {
          id: Fixnum,
          name: String,
          lat: String,
          lon: String,
          street: String,
          city: String,
          state: String,
          zip: String,
          zip_plus_four: String,
          created_at: String,
          updated_at: String
        }
      ].ignore_extra_values!
    }
  end

  describe 'GET #index' do
    context 'when asked for html' do
      it 'should return retailers by address' do
        VCR.use_cassette('get-index-retailers-by-address') do
          get :index, address: address
          assigns(:retailer_presenter).wont_be_nil
          assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
        end
      end

      it 'should respond with 200' do
        VCR.use_cassette('get-index-returns-200') do
          get :index, address: address
          assert_response :success
        end
      end

      it 'should render index template' do
        VCR.use_cassette('retail-controller-index') do
          get :index, address: address
          assert_template :index
        end
      end
    end

    context 'when asked for text' do
      let(:format) { :text }

      it 'should return retailers by address' do
        VCR.use_cassette('retailers-by-address') do
          get :index, format: format, address: address
          assigns(:retailer_presenter).wont_be_nil
          assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
        end
      end

      it 'respond with 200' do
        VCR.use_cassette('retailers-by-address-text-with-200') do
          get :index, format: format, address: address
          assert_response :success
        end
      end

      it 'should render as text' do
        VCR.use_cassette('retailers-by-address-by-text') do
          get :index, format: format, address: address
          response.body.must_equal retailer_presenter.to_text
        end
      end
    end

    context 'when asked for json' do
      let(:format) { :json }

      it 'should return retailers by address' do

        VCR.use_cassette('retail-controller-by-address') do
          get :index, format: format, address: address
          assigns(:retailer_presenter).wont_be_nil
          assigns(:retailer_presenter).retailers.must_equal retailer_presenter.retailers
        end
      end

      it 'should respond with 200' do
        VCR.use_cassette('retailers-json-template-200-response') do
          get :index, format: format, address: address
          assert_response :success
        end
      end

      it 'should respond with 2 retailers' do
        VCR.use_cassette('retailers-json-template') do
          get :index, format: format, address: address
          JSON.parse(response.body).count.must_equal retailer_presenter.retailers.count
        end
      end

      it 'complies with the api spec' do
        VCR.use_cassette('retailers-json-template') do
          server_response = get :index, format: format, address: address
          server_response.body.must_match_json_expression(json_pattern)
        end
      end

    end
  end

  describe 'depreciated retailer action' do
    # not well tested!! accepts json, text
    test 'should GET#nearaddy' do
      VCR.use_cassette('deprecated retailer action nearaddy') do
        get :nearaddy, :address => "22314", :format => :json
        assert_not_nil assigns(:retailers)
        assert_equal assigns(:retailers).count, 2
      end
    end
  end

  # These tests are for the ApplicationController locale logic
  describe "should select proper translation" do
    it "by locale" do
      %w(en es zh).each do |language|
        VCR.use_cassette("translation-by-locale-#{language}") do
          get :index, :locale => language, :address => "22314"
          assert_response :success
          assert locale = language
        end
      end
    end

    it "by request header" do
      %w(en es zh).each do |language|
        request.env['HTTP_ACCEPT_LANGUAGE'] = language
        VCR.use_cassette("translation-by-request-header-#{language}") do
          get :index, :address => "22314"
          assert_response :success
          assert locale = language
        end
      end
    end

    it "form default translation" do
      request.env['HTTP_ACCEPT_LANGUAGE'] = nil
      VCR.use_cassette('translation-default-translation') do
        get :index, :address => "22314"
        assert_response :success
        assert locale = "en"
      end
    end
  end

end
