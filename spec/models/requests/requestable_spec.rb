require 'spec_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :new_episodes } do
  context "as bibliographic record from voyager stored at recap that has an item record" do
    describe "#location_code" do
      it "returns a value voyager location code." do
      end
    end

    describe "#voyager_managed?" do
    end
  end

  context "as a bibliographic record from voyager stored at the annex" do
  end

  context "as a bibliographic record from voyager, a print holding, and an item record that does not circulate" do
    let(:item) {
      {
        id: 4465718,
        status: "Not Charged",
        on_reserve: "N",
        copy_number: 1,
        temp_location: false,
        perm_location: "ctsn",
        enum: false,
        chron: false,
        item_sequence_number: 1,
        status_date: "2006-12-15T11:24:27.000-04:00",
        barcode: "32101054160302"
      }
    }
    let(:location) {
      {
        label: "Cotsen Children's Library",
        code: "ctsn",
        aeon_location: true,
        recap_electronic_delivery_location: false,
        open: false,
        requestable: false,
        always_requestable: true,
        circulates: false,
        library: {
          label: "ReCAP",
          code: "recap"
        }
      }
    }
    let(:holding) {
      {

      }
    }
    let(:bib) {
      {

      }
    }
    let(:params) { { bib: { id: 1 }, holding: { id: 2 }, item: item, location: location } }
    let(:subject) { described_class.new(params) }

    xit "has params needed for a Valid OpenURL" do
      expect(subject).to eq('foo')
    end

    xit "has a summary for the holding" do
      expect(subject.holding.summary).to eq('foobar')
    end

    xit "has an item status" do
      expect(subject.item.status).to eq ('ooo')
    end

    xit "identifies as a ReCAP Item" do
      expect(subject.recap?).to be_truthy
    end
  end

  context "Has a bibliographic record from voyager and a print holding, but no item record" do
    xit "has no item stats" do
    end
  end

  context "It is a bibliographic record that is on order." do
  end

  context "Is a bibliographic record on the shelf" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_on_shelf) }
    let(:requestable) { request.requestable.first }

    describe '#services' do
      it 'has a service on on_shelf' do
        expect(requestable.services.include?('on_shelf')).to be true
      end
    end

    describe '#map_url' do
      it 'returns a map url' do
        expect(requestable.map_url).to match(/^#{Requests.config[:stackmap_base]}/)
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

      it "includes an ItemTitle for a visuals record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq(requestable.bib[:title_display])
      end
    end
  end

  context "Is a bibliographic record from the Graphic Arts collection" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_visuals) }
    let(:requestable) { request.requestable.first }
    let(:holding_id) { 'visuals' }
    let(:formatted_genre) { '[ Print ]' }
    describe "#visuals?" do
      it "returns true when record is a Graphic Arts record" do
        expect(requestable.visuals?).to be_truthy
      end

      it "reports as a non Voyager aeon resource" do
        expect(requestable.aeon?).to be_truthy
      end

      it "includes a valid aeon site value for a visuals record" do
        expect(requestable.aeon_mapped_params.key?(:Site)).to be_truthy
        expect(requestable.aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it "includes a ReferenceNumber" do
        expect(requestable.aeon_mapped_params[:ReferenceNumber]).to eq(request.system_id)
      end

      it "includes the Genre in the ItemTitle for a visuals record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq("#{requestable.bib[:title_display]} #{formatted_genre}")
      end

      it "includes a CallNumber" do
        expect(requestable.aeon_mapped_params[:CallNumber]).to be_truthy
        expect(requestable.aeon_mapped_params[:CallNumber]).to eq(requestable.bib[:call_number_display].first)
      end

      it "includes a sub location" do
        expect(requestable.aeon_mapped_params[:SubLocation]).to be_truthy
        expect(requestable.aeon_mapped_params[:SubLocation]).to eq(requestable.holding.first.last[:location_note].first)
      end
    end
  end

  context "It is in a paging location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_paging_available) }
    let(:requestable) { request.requestable }
    describe "#pageable?" do
      it "should return nil when item status is unavailable" do
        expect(requestable.size).to eq(1)
        # change status
        requestable.first.item["status"] = 'Charged'
        expect(requestable.first.pageable?).to be_falsey
      end

      it "should return true when item status is available" do
        expect(requestable.size).to eq(1)
        expect(requestable.first.pageable?).to be_truthy
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

    describe '#site' do
      it 'should return the correct Aeon Site param' do
        expect(requestable.site).to eq('EAL')
      end
    end

    describe '#barcode' do
      it 'should not report there is a barocode' do
        expect(requestable.barcode?).to be false
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a null barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_rbsc_voyager_enumerated) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['675722'] } }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    let(:enumeration) { 'v.7' }
    describe '#aeon_open_url' do
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

      it 'shouuld have a Referennce NUmber' do
        expect(requestable.aeon_basic_params.key? :ReferenceNumber).to be true
        expect(requestable.aeon_basic_params[:ReferenceNumber]).to eq(requestable.bib[:id])
      end

      it 'shouuld have Location Param' do
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
      it "should have recap request service available" do
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

    let(:request_paging) { FactoryGirl.build(:request_paging_available) }
    let(:requestable_paging) { request_paging.requestable.first }

    describe '# paging requestable' do
      it "should have the Paging request service available" do
        expect(requestable_paging.services.include?('paging')).to be true
      end
    end
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
      it "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "should have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
    end

    let(:request_paging) { FactoryGirl.build(:request_paging_available_barcode_patron) }
    let(:requestable_paging) { request_paging.requestable.first }

    describe '#paging requestable' do
      it "should have the Paging request service available" do
        expect(requestable_paging.services.include?('paging')).to be true
      end
    end

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
      it "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end

      it "should NOT have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be false
      end
    end

    describe '#paging-requestable' do
      let(:request_paging) { FactoryGirl.build(:request_paging_available_unauthenticated_patron) }
      let(:requestable_paging) { request_paging.requestable.first }

      it "should have the Paging request service available" do
        expect(requestable_paging.services.include?('paging')).to be true
      end
    end

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
end
