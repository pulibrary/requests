require 'spec_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :new_episodes } do

  context "with a system_id and a mfhd that has a holding record with an attached item record" do 

    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: '8880549',
        mfhd: '8805567',
        user: user
      }
    }
    let(:request_with_holding_item) { described_class.new(params) }
    subject { request_with_holding_item }

    describe "#doc" do
      it "returns a solr document" do
        expect(subject.doc).to be_truthy
      end
    end

    describe "#display_metadata" do
      it "returns a display title" do
        expect(subject.display_metadata[:title]).to be_truthy
      end

      it "returns a author display" do
        expect(subject.display_metadata[:author]).to be_truthy
      end

      it "returns a display date" do
        expect(subject.display_metadata[:date]).to be_truthy
      end
    end

    describe "#items?" do
      it "Has items" do
        expect(subject.items?).to be_truthy
      end
    end

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "Contains a requestable object with a holding" do
        expect(subject.requestable[0].holding).to be_truthy
      end

      it "Contains a requestable object with an item" do
        expect(subject.requestable[0].item?).to be_truthy
      end

      it "has a mfhd" do
        expect(subject.requestable[0].holding).to be_truthy 
        expect(subject.requestable[0].holding.key? "8805567").to be_truthy
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end
    end

    describe "#load_locations" do
      it "provides a list of location data" do
        expect(subject.locations.size).to eq(1)
        expect(subject.locations.key? 'ues').to be_truthy
      end
    end

    describe "#system_id" do
      it "has a system id" do
        expect(subject.system_id).to be_truthy
        expect(subject.system_id).to eq('8880549')
      end
    end

    describe "#thesis?" do
      it "should not identify itself as a thesis request" do
        expect(subject.thesis?).to be_falsy
      end
    end

    describe "#route_requestable" do
      it "Returns a list of requestable routed items" do
        expect(subject.route_requestable.size).to eq(1)
        expect(subject.route_requestable[0].services).to be_truthy
      end
    end 
  end

  context "with a system_id and a mfhd that only has a holding record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: '1791763',
        mfhd: '2056183',
        user: user
      }
    }
    let(:request_with_only_holding) { described_class.new(params) }
    subject { request_with_only_holding }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a mfhd" do
        expect(subject.requestable[0].holding).to be_truthy
        expect(subject.requestable[0].holding.key? "2056183").to be_truthy
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end
    end
      
  end

  context "with a system_id only that has holdings and item records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '490930',
        user: user
      }
    }

    let(:request_system_id_only_with_holdings_items) { described_class.new(params) }
    subject { request_system_id_only_with_holdings_items }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(98)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(2)
      end
    end

  end

  context "with a system_id that only has holdings records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4758976',
        user: user
      }
    }
    let(:request_system_id_only_with_holdings) { described_class.new(params) }
    subject { request_system_id_only_with_holdings }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(1)
      end
    end
  end

  context "with a system_id that has holdings records that do and don't have item records attached" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2478499',
        user: user
      }
    }
    let(:request_system_id_only_with_holdings_with_some_items) { described_class.new(params) }
    subject { request_system_id_only_with_holdings_with_some_items }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(9)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(9)
      end
    end
  end

  context "A system id that has a holding with items in a temporary location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: '6195942',
        user: user
      }
    }
    let(:request_with_items_at_temp_locations) { described_class.new(params) }
    subject { request_with_items_at_temp_locations }

    describe "#requestable" do
      it "should have a list of requestable objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(7)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "should have location data that reflects an item's temporary location" do
        expect(subject.requestable.first.location["code"]).to eq('scires')
      end

      it "should location data that uses a permenant location when no temporary code is specified" do
        expect(subject.requestable.last.location["code"]).to eq('sci')
      end
    end
  end

  context "a system_id with no holdings or items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: '2385868',
        user: user
      }
    }
    let(:request_with_only_system_id) { described_class.new(params) }
    subject { request_with_only_system_id }

    describe "#requestable" do
      it "should not have a list of request objects" do
        expect(subject.requestable).to be_falsy
      end
    end
  end

  context "When passed a system_id for a theses record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: 'dsp01rr1720547',
        user: user
      }
    }
    let(:request_with_only_system_id) { described_class.new(params) }
    subject { request_with_only_system_id }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "should not have a Voyager location" do
        expect(subject.requestable[0].holding.key? :thesis).to be_truthy
        expect(subject.requestable[0].location.key? 'code').to be_truthy
        expect(subject.requestable[0].location['code']).to eq ('mudd')
      end
    end

    describe "#thesis?" do
      it "should identify itself as a thesis request" do
        expect(subject.thesis?).to be_truthy
      end
    end
  end

  context "When passed an ID for a paging location within allowed call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4472547',
        user: user
      }
    }
    let(:request_at_paging_charged) { described_class.new(params) }
    subject { request_at_paging_charged }
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('nec')
        expect(subject.requestable[0].pageable?).to be_truthy
      end
    end
  end

  context "When passed an ID for a paging location outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2937003',
        user: user
      }
    }
    let(:request_at_paging_outside) { described_class.new(params) }
    subject { request_at_paging_outside }
    
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('nec')
        expect(subject.requestable[0].pageable?).to be_nil
      end
    end
  end

  context "When passed an ID for a paging location outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2942771',
        user: user
      }
    }
    let(:request_at_paging_nec_multiple) { described_class.new(params) }
    subject { request_at_paging_nec_multiple }
    
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('nec')
        expect(subject.requestable[0].pageable?).to eq(true)
      end
    end
  end

  context "When passed an ID for a paging location outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4340413',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }
    
    describe "#pageable?" do
      it "should be be false" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to be_nil
      end
    end
  end
  # 6009363 returned
  context "When passed an ID for a paging location with a call in a range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '6009363',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }
    
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to eq(true)
      end
    end
  end

  # from the A range in "f" 
  context "When passed an ID for a paging location outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9545726',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }
    
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to eq(true)
      end
    end
  end

  ## TODO
  ## Add context for Visuals when available
  ## Add context for EAD when available
end
