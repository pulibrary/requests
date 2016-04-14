require 'spec_helper'

describe Requests::Router, vcr: { cassette_name: 'requests_router', record: :new_episodes } do

  context "A Princeton Community User has signed in" do
    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    describe "Online Holding" do
      let(:params) { { system_id: 1, holding_id: 2, item_id: 3 } }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:subject) { described_class.new(requestable, user) }

      it "Returns an Online Link" do
        expect(subject.services).to have_key?(:full_text)
      end
    end

    describe "Print Holding in RBSC without items" do
      let(:params) { { system_id: 4, holding_id: 5, item_id: 6 } }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:subject) { described_class.new(requestable, user) }
      it "Returns an Aeon Reading Room Link" do
        expect(subject.services).to have_key?(:reading_room)
      end
    end

    describe "Print Holding in RBSC with item record and open pickup locations" do
    end

    describe "Print Holding in RBSC with item record and restricted pickup locations" do
    end

    describe "Print Holding at ReCAP with charged item" do
    end

    describe "Print Holding at ReCAP with EDD eligible item" do
    end

    describe "Annex Holding without item" do
    end

    describe "Annex Holding with item" do
    end

    describe "Open Holding with item" do
    end

    describe "Open Holding without item" do
    end

    describe "Open Holding with Charaged Item" do
    end

    describe "Thesid Collection Item" do
    end
  end

  # Fill in when we support guest authentication
  # context "An Access Patron has signed in" do
  #   let(:user) { FactoryGirl.create(:valid_access_patron) }
   
  #   describe "Print Holding with Charged Item"
  #   end
  # end

  # context "The user has not authenticated but can self-identify as an access patron" do
  #   let(:user) { FactoryGirl.create(:unauthenticated_patron) }
    
  #   describe "Print Holding with Charge Item" do
  #   end
  # end

end