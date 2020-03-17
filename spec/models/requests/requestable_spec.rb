require 'spec_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :new_episodes } do
  context "Is a bibliographic record on the shelf" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_on_shelf) }
    let(:requestable) { request.requestable.first }
    let(:mfhd_id) { requestable.holding.first[0] }
    let(:call_number) { CGI.escape(requestable.holding[mfhd_id]['call_number']) }
    let(:location_code) { requestable.holding[mfhd_id]['location_code'] }
    let(:stackmap_url) { requestable.map_url(mfhd_id) }

    describe '#services' do
      it 'has a service on on_shelf' do
        expect(requestable.services.include?('on_shelf')).to be true
      end
    end

    describe '#map_url' do
      it 'returns a stackmap url' do
        expect(stackmap_url).to include("#{requestable.bib[:id]}/stackmap?cn=#{call_number}&loc=#{location_code}")
      end
    end
  end

  context "Is a bibliographic record from the thesis collection" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_thesis) }
    let(:requestable) { request.requestable.first }
    let(:holding_id) { "thesis" }
    describe "#thesis?" do
      it "returns true when record is a senior thesis" do
        expect(requestable.thesis?).to be_truthy
      end

      it "reports as a non Voyager aeon resource" do
        expect(requestable.aeon?).to be_truthy
        expect(requestable.non_voyager?(holding_id)).to be_truthy
      end

      it "returns a params list with an Aeon Site MUDD" do
        expect(requestable.aeon_mapped_params.key?(:Site)).to be_truthy
        expect(requestable.aeon_mapped_params[:Site]).to eq('MUDD')
      end

      it "includes a ReferenceNumber" do
        expect(requestable.aeon_mapped_params[:ReferenceNumber]).to eq(request.system_id)
      end

      it "includes a CallNumber" do
        expect(requestable.aeon_mapped_params[:CallNumber]).to be_truthy
        expect(requestable.aeon_mapped_params[:CallNumber]).to eq(requestable.bib[:call_number_display].first)
      end

      it "includes an ItemTitle for a senior thesis record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq(requestable.bib[:title_display])
      end
    end
  end

  context 'A requestable item with a missing status' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_missing_item) }
    let(:requestable) { request.requestable }
    describe "#services" do
      it "should return an item status of missing" do
        expect(requestable.size).to eq(2)
        requestable.first.item["status"] = 'Missing'
        expect(requestable.first.services).to be_truthy
      end

      it 'should not be recallable' do
        expect(requestable.first.services.include?('recall')).to be_falsey
      end

      it 'should be available via borrow direct' do
        expect(requestable.first.services.include?('bd')).to be_truthy
      end

      it 'should be available via ILL' do
        expect(requestable.first.services.include?('ill')).to be_truthy
      end
    end
  end

  context 'A requestable item with hold_request status' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_serial_with_item_on_hold) }
    let(:requestable_on_hold) { request.requestable[8] }
    let(:requestable_not_on_hold) { request.requestable.first }
    describe '#hold_request?' do
      it 'with a Hold Request status it should be on hold' do
        expect(requestable_on_hold.hold_request?).to be true
      end
      it 'should be on hold with a Not Charged status' do
        expect(requestable_not_on_hold.hold_request?).to be false
      end
    end

    describe '#services' do
      it 'should not be recallable' do
        expect(requestable_on_hold.services.include? 'recall').to be false
        expect(requestable_on_hold.recallable?).to be false
      end
    end
  end

  context 'A requestable item eligible for borrow direct' do
    let(:request) { FactoryGirl.build(:missing_item) }
    let(:requestable) { request.requestable }
    describe '#services' do
      it 'should not be recallable' do
        expect(requestable.first.services.include?('recall')).to be false
      end

      it 'should not be recallable' do
        expect(requestable.first.recallable?).to be false
      end

      it 'should be missing' do
        expect(requestable.first.missing?).to be true
      end

      it 'should be eligible for borrow direct' do
        expect(requestable.first.borrow_direct?).to be true
      end

      it 'should be eligible for ill' do
        expect(requestable.first.ill_eligible?).to be true
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a null barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_eal_voyager_item) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#services' do
      it 'should be eligible for aeon services' do
        expect(requestable.services.include?('aeon')).to be true
      end
    end

    describe '#aeon_open_url' do
      it 'should return an openurl with a Call Number param' do
        expect(requestable.aeon_openurl(request.ctx)).to be_a(String)
      end
    end

    describe '#barcode' do
      it 'should not report there is a barocode' do
        expect(requestable.barcode?).to be false
      end
    end
  end

  context 'A requestable serial item that has volume and item data in its openurl' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_rbsc_enumerated) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['6720550'] } }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    describe '#aeon_open_url' do
      it 'should return an openurl with volume data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(requestable.item[:enum])}")
      end

      it 'should return an openurl with issue data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.issue=#{CGI.escape(requestable.item[:chron])}")
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a null barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_rbsc_voyager_enumerated) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['675722'] } }
    let(:holding_id) { '675722' }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    let(:enumeration) { 'v.7' }

    describe '#aeon_open_url' do
      it 'identifies as an aeon eligible voyager mananaged item' do
        expect(requestable.aeon?).to be true
        expect(requestable.non_voyager?(holding_id)).to be false
      end

      it 'should return an openurl with enumeration when available' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(enumeration)}")
      end

      it 'should return an openurl with item id as a value for iteminfo5' do
        expect(requestable.aeon_openurl(request.ctx)).to include("iteminfo5=#{requestable.item[:id]}")
      end
    end
  end

  context 'A requestable item from a RBSC holding without an item record' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_no_item_record) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#barcode?' do
      it 'should not have a barcode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#site' do
      it 'should return a RBSC site param' do
        expect(requestable.site).to eq('RBSC')
      end
    end
  end

  context 'A MUDD holding' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_mudd) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'should return a RBSC site param' do
        expect(requestable.site).to eq('MUDD')
      end
    end
  end

  context 'A Marquand holding' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_marquand) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'should return a Marquand site param' do
        expect(requestable.site).to eq('MARQ')
      end
    end
  end

  context 'A requestable item from a RBSC holding that has a long title' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_w_long_title) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#aeon_basic_params' do
      it 'includes a Title Param that is less than 250 characters' do
        expect(requestable.aeon_mapped_params.key? :ItemTitle).to be true
        expect(requestable.aeon_mapped_params[:ItemTitle].length).to be <= 250
      end
    end
    describe '#ctx' do
      it 'truncates the open url ctx title' do
        expect(request.ctx.referent.metadata['btitle'].length).to be <= 250
        expect(request.ctx.referent.metadata['title'].length).to be <= 250
      end
    end
  end

  context 'A requestable item from a RBSC holding with an item record including a barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_w_barcode) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#barcode?' do
      it 'should have a barcode' do
        expect(requestable.barcode?).to be true
        expect(requestable.barcode).to match(/^[0-9]+/)
      end
    end

    describe '#aeon_openurl' do
      it 'returns an OpenURL CTX Object' do
        expect(aeon_ctx).to be_a(String)
      end

      it 'includes an ItemNumber Param' do
        expect(aeon_ctx).to include(requestable.barcode)
      end

      it 'includes a Site Param' do
        expect(aeon_ctx).to include(requestable.site)
      end

      it 'includes a Genre Param' do
        expect(aeon_ctx).to include('rft.genre=book')
      end

      it 'includes a Call Number Param' do
        expect(aeon_ctx).to include('CallNumber')
      end
    end

    describe '#aeon_basic_params' do
      it 'should include a Site param' do
        expect(requestable.aeon_basic_params.key? :Site).to be true
        expect(requestable.aeon_basic_params[:Site]).to eq('RBSC')
      end

      it 'should have a Reference NUmber' do
        expect(requestable.aeon_basic_params.key? :ReferenceNumber).to be true
        expect(requestable.aeon_basic_params[:ReferenceNumber]).to eq(requestable.bib[:id])
      end

      it 'should have Location Param' do
       expect(requestable.aeon_basic_params.key? :Location).to be true
       expect(requestable.aeon_basic_params[:Location]).to eq(requestable.holding.first.last['location_code'])
     end
    end

    describe '#aeon_request_url' do
      it 'beings with Aeon GFA base' do
        expect(requestable.aeon_request_url(request.ctx)).to match(/^#{Requests.config[:aeon_base]}/)
      end
    end
  end

  context 'A requestable item from Forrestal Annex with no item data' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_no_items) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe 'requestable with no items ' do
      it 'should not have item data' do
        expect(requestable.has_item_data?).to be false
      end
    end
  end

  context 'On Order materials' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_on_order) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe 'with a status of on_order ' do
      it 'should be on_order ' do
        expect(requestable.on_order?).to be true
      end
    end
  end

  context 'Pending Order materials' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_pending) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe 'with a status of pending orders' do
      it 'should be treated like on order items ' do
        expect(requestable.on_order?).to be true
      end
    end
  end

  # user authentication tests
  context 'When a princeton user with NetID visits the site' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9999800',
        user: user
      }
    }
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '# offsite requestable' do
      # TODO: Remove when campus has re-opened
      it "should not have recap request service available during campus closure" do
        expect(requestable.services.include?('recap')).to be false
      end
      # TODO: Activate test when campus has re-opened
      xit "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "should have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
    end

    let(:request_charged) { FactoryGirl.build(:request_with_items_charged) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding['1594698'] } }
    let(:requestable_charged) { requestable_holding.first }

    describe '# checked-out requestable' do
      it "should have borrow direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be true
      end

      it "should have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be true
      end

      it "should have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be true
      end
    end

    let(:request_missing) { FactoryGirl.build(:request_missing_item) }
    let(:requestable_missing) { request_missing.requestable.first }

    describe '# missing requestable' do
      it "should have borrow direct request service available" do
        expect(requestable_missing.services.include?('bd')).to be true
      end

      it "should have ILL request service available" do
        expect(requestable_missing.services.include?('ill')).to be true
      end

      it "should NOT have recall request service available" do
        expect(requestable_missing.services.include?('recall')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryGirl.build(:aeon_mudd) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '# reading_room requestable' do
      it "should have Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end

    # let(:request_paging) { FactoryGirl.build(:request_paging_available) }
    # let(:requestable_paging) { request_paging.requestable.first }

    # describe '# paging requestable' do
    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end
  end

  context 'When a barcode only user visits the site' do
    let(:user) { FactoryGirl.build(:valid_barcode_patron) }
    let(:params) {
      {
        system_id: '9999800',
        user: user
      }
    }
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#requestable' do
      # TODO: Remove when campus has re-opened
      it "should not have recap request service available during campus closure" do
        expect(requestable.services.include?('recap')).to be false
      end
      # TODO: Activate test when campus has re-opened
      xit "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "should have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
    end

    # let(:request_paging) { FactoryGirl.build(:request_paging_available_barcode_patron) }
    # let(:requestable_paging) { request_paging.requestable.first }

    # describe '#paging requestable' do
    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end

    let(:request_charged) { FactoryGirl.build(:request_with_items_charged_barcode_patron) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding['1594698'] } }
    let(:requestable_charged) { requestable_holding.first }

    describe '#checked-out requestable' do
      it "should have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be true
      end

      # Barcode users should NOT have the following privileges ...

      it "should NOT have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      it "should NOT have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryGirl.build(:aeon_mudd_barcode_patron) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '#reading room requestable' do
      it "should have Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end
  end

  context 'When an access only user visits the site' do
    let(:user) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) {
      {
        system_id: '9999800',
        user: user
      }
    }
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#recap requestable' do
      # TODO: Remove when campus has re-opened
      it "should not have recap request service available during campus closure" do
        expect(requestable.services.include?('recap')).to be false
      end
      # TODO: Activate test when campus has re-opened
      xit "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end

      it "should NOT have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be false
      end
    end

    # describe '#paging-requestable' do
    #   let(:request_paging) { FactoryGirl.build(:request_paging_available_unauthenticated_patron) }
    #   let(:requestable_paging) { request_paging.requestable.first }

    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end

    let(:request_aeon_mudd) { FactoryGirl.build(:aeon_mudd_unauthenticated_patron) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '#reading room requestable' do
      it "should have Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end

    # Barcode users should NOT have the following privileges ...
    let(:request_charged) { FactoryGirl.build(:request_with_items_charged_unauthenticated_patron) }
    let(:requestable_charged) { request_charged.requestable.first }

    describe '#checked-out requestable' do
      it "should NOT have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be false
      end

      it "should NOT have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      it "should NOT have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end
  end
  context 'A requestable item from a RBSC holding creates an openurl with volume and call number info' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_aeon_holding_volume_note) }
    let(:requestable) { request.requestable.select { |m| m.holding.first.first == '675722' }.first }
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#aeon_openurl' do
      it 'includes the location_has note as the volume' do
        expect(aeon_ctx).to include('rft.volume=v.7')
      end

      it 'includes the call number of the holding' do
        expect(aeon_ctx).to include('CallNumber=2015-0801N')
      end
    end
  end
  context 'A SCSB Item from a location with no pickup restrictions' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_cu) }
    let(:requestable) { request.requestable.first }
    describe '#pickup_locations' do
      it 'has a single pickup location' do
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('QX')
      end
    end
  end
  context 'A SCSB Item from a location with a pickup restrictions' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_ar) }
    let(:requestable) { request.requestable.first }
    describe '#pickup_locations' do
      it 'has a single pickup location' do
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('PJ')
      end
    end
  end
  context 'A SCSB Item from a location with no pickup restrictions' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_mr) }
    let(:requestable) { request.requestable.first }
    describe '#pickup_locations' do
      it 'has a single pickup location' do
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('PK')
      end
    end
  end
end
