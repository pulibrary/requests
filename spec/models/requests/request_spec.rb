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
        expect(subject.has_pageable?).to be_nil
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(2)
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(2)
      end

      it "assigns items to the correct mfhd" do
        subject.sorted_requestable.each do |key, items| 
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
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
        expect(subject.requestable.first.location["code"]).to eq('sciresp')
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

      it "should have a thesis holding location" do
        expect(subject.requestable[0].holding.key? 'thesis').to be_truthy
        expect(subject.requestable[0].location.key? 'code').to be_truthy
        expect(subject.requestable[0].location['code']).to eq ('mudd')
        expect(subject.requestable[0].voyager_managed?).to be_nil
      end
    end

    describe "#thesis?" do
      it "should identify itself as a thesis request" do
        expect(subject.thesis?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        subject.sorted_requestable.each do |key, items| 
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end
  end


  context "When passed a system_id for a visuals record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: 'visuals45246',
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
        expect(subject.requestable[0].holding.key? 'visuals').to be_truthy
        expect(subject.requestable[0].location.key? 'code').to be_truthy
        expect(subject.requestable[0].location['code']).to eq ('ga')
        expect(subject.requestable[0].voyager_managed?).to be_nil
      end
    end

    describe "#visuals?" do
      it "should identify itself as a visuals request" do
        expect(subject.visuals?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(1)
      end

      it "should not have any items attached" do
        expect(subject.items?).to be_nil
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
        expect(subject.has_pageable?).to be(true)
        expect(subject.requestable[0].location['code']).to eq('nec')
        expect(subject.requestable[0].pageable?).to be_truthy
      end
    end
  end

  context "When passed an ID for a paging location in nec outside of call number range" do
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
        expect(subject.has_pageable?).to be_nil
        expect(subject.requestable[0].pageable?).to be_nil
      end
    end
  end

  context "When passed an ID for a paging location in nec  within a paging call number range" do
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

    describe "#has_pageable?" do
      it "should return true when all requestable items are pageable?" do
        expect(subject.has_pageable?).to be_truthy
      end

      it "should return true when only some of the requestable items are pageable?" do
        subject.requestable.first.item["status"] = 'Charged'
        expect(subject.has_pageable?).to be_truthy
      end

      it "should return false when all requestable items are not pageable?" do
        subject.requestable.each do |requestable|
          requestable.item["status"] = 'Charged'
          requestable.services = []
        end
        expect(subject.has_pageable?).to be_falsy
      end 
    end
  end

  context "When passed an ID for a paging location in f outside of call number range" do
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
  context "When passed an ID for a paging location f within a call in a range" do
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
        expect(subject.has_pageable?).to be(true)
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to eq(true)
        expect(subject.requestable[0].pickup_locations.size).to eq(1)
      end
    end
  end

  # from the A range in "f" 
  context "When passed an ID for a paging location f outside of call number range" do
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
        expect(subject.has_pageable?).to be(true)
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end
    end
  end

  context "When passed an ID for an xl paging location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9596359',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }
    
    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('xl')
        expect(subject.requestable[0].pageable?).to eq(true)
        expect(subject.has_pageable?).to be(true)
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end
    end
  end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602549',
        user: user
      }
    }
    let(:request_with_on_order) { described_class.new(params) }
    let(:firestone_circ) { "Firestone Library" }
    subject { request_with_on_order }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end

      it "should provide a list of the default pickup locations" do
        expect(subject.default_pickups).to be_truthy
        expect(subject.default_pickups).to be_an(Array)
        expect(subject.default_pickups.size).to be > 1
        expect(subject.default_pickups.include?(firestone_circ)).to be_truthy 
      end
    end
  end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602551',
        mfhd: '9442918',
        user: user
      }
    }
    let(:request_with_on_order) { described_class.new(params) }
    subject { request_with_on_order }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end
    end
  end

  # Oversize ID 
  context "When passed an ID for an Item with that is Oversize" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '3785401',
        user: user
      }
    }
    let(:request_oversize) { described_class.new(params) }
    subject { request_oversize }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be in a location that contains some pageable items" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end

      it "should be have pageable items" do
        expect(subject.has_pageable?).to be(true)
      end        

      it "should have a pageable item" do
        expect(subject.requestable[0].pageable?).to eq(true)
      end
    end
  end

  # Item with no call number 9602545
  context "When passed an ID for an Item in a pageable location that has no call number" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602545',
        user: user
      }
    }
    let(:request_no_callnum) { described_class.new(params) }
    subject { request_no_callnum }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be in a pageable location" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end

      it "should not have any pageable items" do
        expect(subject.has_pageable?).to be_nil
      end        

      it "should have a pageable item" do
        expect(subject.requestable[0].pageable?).to be_nil
      end
    end
  end
  ## Add context for Visuals when available
  ## Add context for EAD when available
  # http://localhost:4000/requests/2002206?mfhd=2281830
  context "When passed a mfhd with missing items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2002206',
        mfhd: '2281830',
        user: user
      }
    }
    let(:request_with_missing) { described_class.new(params) }
    subject { request_with_missing }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should show missing items as eligible for ill" do
        expect(subject.requestable[2].services.include?('ill')).to be_truthy
      end
    end
  end

  context "When passed an Aeon ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9627261',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should show item as aeon eligble" do
        expect(subject.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When passed an Aeon holding ID with no items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '616086',
        mfhd: '5132984',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to eq(1)
      end

      it "should not have any barcode data" do
        expect(subject.requestable.first.item[:barcode]).to be_nil
      end

      it "should be eligible for aeon services" do
        expect(subject.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9676483',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.first.services.include?('recap')).to be_truthy
      end

      it "should be eligible for recap_edd services" do
        expect(subject.requestable.first.services.include?('recap_edd')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID and mfhd for a serial at a non EDD location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '426420',
        mfhd: '464640',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.last.services.include?('recap')).to be_truthy
      end

      it "should be eligible for recap_edd services" do
        expect(subject.requestable.last.services.include?('recap_edd')).to be_falsy
      end
    end
  end

  context "When passed a Recallable Item that is eligible for Borrow Direct" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9738136',
        mfhd: '9558038',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.first.services.size).to eq(3)
      end

      it "should be eligible for ill services" do
        expect(subject.requestable.first.services.include?('ill')).to be_truthy
      end

      it "should be eligible for borrow direct services" do
        expect(subject.requestable.first.services.include?('bd')).to be_truthy
      end

      it "should be eligible for recall" do
        expect(subject.requestable.first.services.include?('recall')).to be_truthy
      end
    end
  end

  context 'When passed an item that is traceable and mappable' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9907433',
        mfhd: '9723988',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for multiple services" do
        expect(subject.requestable.first.services.size).to eq(2)
      end

      it "should be eligible for trace services" do
        expect(subject.requestable.first.services.include?('trace')).to be_truthy
      end

      it "should be eligible for recall" do
        expect(subject.requestable.first.services.include?('on_shelf')).to be_truthy
      end

    end
  end

end
