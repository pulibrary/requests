require 'spec_helper'

describe Requests::Router, vcr: { cassette_name: 'requests_router', record: :new_episodes } do
  context "A Princeton Community User has signed in" do
    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    describe "Online Holding" do
      let(:params) { {} }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:subject) { described_class.new(requestable, user) }
      xit "Returns an Online Link" do
        expect(subject.services.key?(:full_text)).to be_truthy
      end
    end

    describe "Print Holding in RBSC without items" do
      let(:params) { { system_id: 4, holding_id: 5, item_id: 6 } }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:subject) { described_class.new(requestable, user) }
      xit "Returns an Aeon Reading Room Link" do
        expect(subject.services.key?(:reading_room)).to be_truthy
      end
    end

    describe "Print Holding in ReCAP with item record and open pickup locations" do
    end

    describe "Print Holding in ReCAP with item record and restricted pickup locations" do
    end

    describe "Print Holding at ReCAP with charged item" do
    end

    describe "Print Holding at ReCAP with EDD eligible item" do
    end

    describe "Annex Holding without item" do
    end

    describe "Annex Holding with item" do
      it "has pickup locations" do
      end
    end

    describe "Annex Holding with charged item" do
    end

    context "When an item is in a pageable location" do
      describe "It has a unavilable status" do
      end
    end

    context "When a firestone item" do
      describe "Open Holding with item" do
        xit "has a firestone locator link when a firestone item" do
          expect(subject.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    context "When a non-frestone item" do
      describe "Open Holding with item" do
        xit "has a stackmap link when a firestone item" do
          expect(subject.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    describe "Open Holding with charged item" do
    end

    describe "Open Holding without item" do
    end

    describe "Open Holding with Charged Item" do
    end

    describe "Thesis Collection Item" do
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
