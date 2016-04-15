require 'spec_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :new_episodes } do

  context "Voyager Record Request Options" do 

    let(:request_aeon) { FactoryGirl.build(:request_aeon) }
    let(:request_online) { FactoryGirl.build(:request_online) }
    let(:request_no_items) { FactoryGirl.build(:request_no_items) }
    let(:request_on_order) { FactoryGirl.build(:request_on_order) }
    let(:request_always_available_no_items) { FactoryGirl.build(:request_always_available_no_items)}
    let(:request_thesis) { FactoryGirl.build(:request_thesis) }

    # before(:each) do
    #   # stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/1.json").
    #   #   with(:headers => {'User-Agent'=>'Faraday v0.9.2'}).
    #   #   to_return(:status => 200, :body => "Foo", :headers => {})
    #   stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    #     stub.get("#{Requests.config[:pulsearch_base]}/catalog/1.json") { |env| [200, {}, 'egg'] }
    #     stub.get("#{Requests.config[:bibdata_base]}/bibliographic/1/items") { |env| [200, {}, 'egg'] }
    #     stub.get("#{Requests.config[:bibdata_base]}/bibliographic/1") { |env| [200, {}, 'egg'] }
    #   end


    # end

    ### All these tests need re-factoring 
    it "Requests has holdings" do
      expect(request_aeon.holdings?).to be_truthy
    end

    it "Online Resource" do
      expect(request_online.has_online_holdings?).to be_truthy
    end

    it "Is located at an Open Access Location" do
      expect(request_no_items.has_items?).to be_nil
    end

    it "Is an On Order Request" do
      expect(request_no_items.on_order?).to be_nil
      expect(request_on_order.on_order?).to be_truthy
    end

    it "Is located at Restricted Access, Always Requestable location" do
      expect(request_always_available_no_items.available?).to be_truthy
    end

    xit "Has location business logic available" do
    end

  end

  #   context "Has item Records" do

  #     describe "Available Resource" do

  #       it "Is in an open location" do
  #       end  

  #       it "Is in a restricted location" do
  #       end

  #     end

  #     describe "Unavailable Resource" do
  #       it "Is in an open location" do
  #       end  

  #       it "Is in a restricted location" do
  #       end
  #     end

  #   end

  # end

  #   context "Non-Voyager Record Request" do
      
  #     let (:request)  { FactoryGirl.create(:request) }

  #     context "Online item" do
  #       xit "It Should Provide a Link to the Digital Copy" do
  #       end
  #     end

  #     context "Physical item" do
  #       xit "It Should provide a valid request option" do
  #       end
  #     end

  #   end

  #   context "Current User" do

  #     context "Request Has Valid PUL User" do
  #     end

  #     context "Request has Valid Guest User" do
  #     end

  #     context "Request has Invalid PUL User" do
  #     end

  #     context "Request has an Invalid Guest User" do
  #     end
  #   end

  end