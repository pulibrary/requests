require 'spec_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :none } do
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
        expect(requestable.services).to contain_exactly('on_shelf', 'on_shelf_edd')
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library')
      end
    end

    describe '#map_url' do
      it 'returns a stackmap url' do
        expect(stackmap_url).to include("#{requestable.bib[:id]}/stackmap?cn=#{call_number}&loc=#{location_code}")
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
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

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Mudd Manuscript Library')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context "Is a bibliographic record from the numismatics collection" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_numismatics) }
    let(:requestable) { request.requestable.first }
    let(:holding_id) { "numismatics" }
    describe "#numismatics?" do
      it "returns true when record is a senior thesis" do
        expect(requestable.numismatics?).to be_truthy
      end

      it "reports as a non Voyager aeon resource" do
        expect(requestable.aeon?).to be_truthy
        expect(requestable.non_voyager?(holding_id)).to be_truthy
      end

      it "returns a params list with an Aeon Site RBSC" do
        expect(requestable.aeon_mapped_params.key?(:Site)).to be_truthy
        expect(requestable.aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it "includes a ReferenceNumber" do
        expect(requestable.aeon_mapped_params[:ReferenceNumber]).to eq(request.system_id)
      end

      it "includes a CallNumber" do
        expect(requestable.aeon_mapped_params[:CallNumber]).to be_truthy
        expect(requestable.aeon_mapped_params[:CallNumber]).to eq(requestable.bib[:call_number_display].first)
      end

      it "includes an ItemTitle for a numismatics record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq(requestable.bib[:title_display])
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Numismatics Collection')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable item with a missing status' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_missing_item) }
    let(:requestable) { request.requestable }
    describe "#services" do
      it "returns an item status of missing" do
        expect(requestable.size).to eq(2)
        requestable.first.item["status"] = 'Missing'
        expect(requestable.first.services).to be_truthy
      end

      it 'is not recallable' do
        expect(requestable.first.services.include?('recall')).to be_falsey
      end

      # TODO: Remove when campus has re-opened
      it 'is not available via borrow direct' do
        expect(requestable.first.services.include?('bd')).to be_falsey
      end

      # TODO: Activate test when campus has re-opened
      xit 'should be available via borrow direct' do
        expect(requestable.first.services.include?('bd')).to be_truthy
      end

      # TODO: Remove when campus has re-opened
      it 'is not available via ILL' do
        expect(requestable.first.services.include?('ill')).to be_falsey
      end

      # TODO: Activate test when campus has re-opened
      xit 'should be available via ILL' do
        expect(requestable.first.services.include?('ill')).to be_truthy
      end

      describe '#location_label' do
        it 'has a location label' do
          expect(requestable.first.location_label).to eq('Firestone Library')
        end
      end

      describe '#libcal_url' do
        it "is available for appointment" do
          expect(requestable.first.libcal_url).to be_nil
        end
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
      it 'is on hold with a Not Charged status' do
        expect(requestable_not_on_hold.hold_request?).to be false
      end
    end

    describe '#services' do
      it 'is not recallable' do
        expect(requestable_on_hold.services.include?('recall')).to be false
        expect(requestable_on_hold.recallable?).to be false
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable_on_hold.location_label).to eq('ReCAP')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable_on_hold.libcal_url).to be_nil
        expect(requestable_not_on_hold.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable item eligible for borrow direct' do
    let(:request) { FactoryGirl.build(:missing_item) }
    let(:requestable) { request.requestable }
    describe '#services' do
      it 'is does not have a recall service' do
        expect(requestable.first.services.include?('recall')).to be false
      end

      it 'is not recallable' do
        expect(requestable.first.recallable?).to be false
      end

      it 'is missing' do
        expect(requestable.first.missing?).to be true
      end

      # TODO: Remove when campus has re-opened
      it 'is not eligible for borrow direct' do
        expect(requestable.first.borrow_direct?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit 'should be eligible for borrow direct' do
        expect(requestable.first.borrow_direct?).to be true
      end

      # TODO: Remove when campus has re-opened
      it 'is not eligible for ill' do
        expect(requestable.first.ill_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit 'should be eligible for ill' do
        expect(requestable.first.ill_eligible?).to be true
      end

      describe '#location_label' do
        it 'has a location label' do
          expect(requestable.first.location_label).to eq('Firestone Library')
        end
      end

      describe '#libcal_url' do
        it "is available for appointment" do
          expect(requestable.first.libcal_url).to be_nil
        end
      end
    end
  end

  context 'A non circulating item' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:mfhd_with_no_circ_and_circ_item) }
    let(:requestable) { request.requestable[12] }
    # let(:item) { barcode :"32101024595744", id: 282_632, location: "f", copy_number: 1, item_sequence_number: 14, status: "Not Charged", on_reserve: "N", item_type: "NoCirc", pickup_location_id: 299, pickup_location_code: "fcirc", enum: "vol.22", "chron": "1996", enum_display: "vol.22 (1996)", label: "Firestone Library" }
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pickup_location_id) { requestable.item['pickup_location_id'] }
    let(:no_circ_pickup_location_code) { requestable.item['pickup_location_code'] }

    # rubocop:disable RSpec/MultipleExpectations
    describe 'getters' do
      it 'gets values' do
        expect(requestable.item_data?).to be true
        expect(requestable.item_type_non_circulate?).to be true
        expect(requestable.pickup_location_id).to eq 299
        expect(requestable.pickup_location_code).to eq 'fcirc'
        expect(requestable.enum_value).to eq 'vol.22'
        expect(requestable.cron_value).to eq '1996'
        expect(requestable.location_label).to eq('Firestone Library')
        expect(requestable.libcal_url).to eq("https://libcal.princeton.edu/seats?lid=1919")
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations

  context 'A circulating item' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:mfhd_with_no_circ_and_circ_item) }
    let(:requestable) { request.requestable[0] }
    # let(:item) {"barcode":"32101022548893","id":282628,"location":"f","copy_number":1,"item_sequence_number":10,"status":"Not Charged","on_reserve":"N","item_type":"Gen","pickup_location_id":299,"pickup_location_code":"fcirc","enum":"vol.18","chron":"1992","enum_display":"vol.18 (1992)","label":"Firestone Library"}
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pickup_location_id) { requestable.item['pickup_location_id'] }
    let(:no_circ_pickup_location_code) { requestable.item['pickup_location_code'] }

    describe '#item_type_circulate' do
      it 'returns the item type from voyager' do
        expect(requestable.item_type_non_circulate?).to be false
        expect(requestable.pickup_location_id).to eq 299
        expect(requestable.pickup_location_code).to eq 'fcirc'
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a null barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_eal_voyager_item) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#services' do
      it 'is eligible for aeon services' do
        expect(requestable.services.include?('aeon')).to be true
      end
    end

    describe '#aeon_open_url' do
      it 'returns an openurl with a Call Number param' do
        expect(requestable.aeon_openurl(request.ctx)).to be_a(String)
      end
    end

    describe '#barcode' do
      it 'does not report there is a barocode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('East Asian Library - Rare Books')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable serial item that has volume and item data in its openurl' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_rbsc_enumerated) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['6720550'] } }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    describe '#aeon_open_url' do
      it 'returns an openurl with volume data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(requestable.item[:enum])}")
      end

      it 'returns an openurl with issue data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.issue=#{CGI.escape(requestable.item[:chron])}")
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('ReCAP - Rare Books Off-Site Storage')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
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

      it 'returns an openurl with enumeration when available' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(enumeration)}")
      end

      it 'returns an openurl with item id as a value for iteminfo5' do
        expect(requestable.aeon_openurl(request.ctx)).to include("iteminfo5=#{requestable.item[:id]}")
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Rare Books')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable item from a RBSC holding without an item record' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_no_item_record) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#barcode?' do
      it 'does not have a barcode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#site' do
      it 'returns a RBSC site param' do
        expect(requestable.site).to eq('RBSC')
      end
    end

    describe '#aeon_openurl' do
      let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }

      it 'includes basic metadata' do
        expect(aeon_ctx).to include('&rft.genre=unknown&rft.title=Beethoven%27s+andante+cantabile+aus+dem+Trio+op.+97%2C+fu%CC%88r+orchester&rft.creator=Beethoven%2C+Ludwig+van&rft.aucorp=Leipzig%3A+Kahnt&rft.pub=Leipzig%3A+Kahnt&rft.format=musical+score&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Aunknown&rft_id=https%3A%2F%2Fbibdata.princeton.edu%2Fbibliographic%2F2535845&rft_id=info%3Aoclcnum%2F25615303&rfr_id=info%3Asid%2Fcatalog.princeton.edu%3Agenerator&CallNumber=M1004.L6+B3&ItemInfo1=Reading+Room+Access+Only&Location=ex&ReferenceNumber=2535845&Site=RBSC')
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Rare Books')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A MUDD holding' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_mudd) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'returns a RBSC site param' do
        expect(requestable.site).to eq('MUDD')
      end
    end
  end

  context 'A Recap Marquand holding' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_marquand) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'returns a Marquand site param' do
        expect(requestable.site).to eq('MARQ')
        expect(requestable.available_for_digitizing?).to be_truthy
        expect(requestable.can_be_delivered?).to be_falsey
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('ReCAP - Marquand Library (Rare) use only')
      end
    end

    describe '#available_for_appointment?' do
      it "is available for appointment" do
        expect(requestable.available_for_appointment?).to be_falsey
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A Non-Recap Marquand holding' do
    let(:requestable) { Requests::Requestable.new(bib: {}, holding: [{ 1 => { 'call_number_browse': 'blah' } }], location: { "holding_library" => { "code" => "marquand" }, "library" => { "code" => "marquand" } }, user_barcode: '111222333') }

    describe '#site' do
      it 'returns a Marquand site param' do
        expect(requestable.in_library_use_only?).to be_truthy
      end
    end
    describe '#available_for_appointment?' do
      it "is available for appointment" do
        expect(requestable.available_for_appointment?).to be_truthy
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to eq('https://libcal.princeton.edu/seats?lid=10656')
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
        expect(requestable.aeon_mapped_params.key?(:ItemTitle)).to be true
        expect(requestable.aeon_mapped_params[:ItemTitle].length).to be <= 250
      end
    end
    describe '#ctx' do
      it 'truncates the open url ctx title' do
        expect(request.ctx.referent.metadata['btitle'].length).to be <= 250
        expect(request.ctx.referent.metadata['title'].length).to be <= 250
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - John Witherspoon Library')
      end
    end
  end

  context 'A requestable item from a RBSC holding with an item record including a barcode' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:aeon_w_barcode) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#barcode?' do
      it 'has a barcode' do
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
      it 'includes a Site param' do
        expect(requestable.aeon_basic_params.key?(:Site)).to be true
        expect(requestable.aeon_basic_params[:Site]).to eq('RBSC')
      end

      it 'has a Reference NUmber' do
        expect(requestable.aeon_basic_params.key?(:ReferenceNumber)).to be true
        expect(requestable.aeon_basic_params[:ReferenceNumber]).to eq(requestable.bib[:id])
      end

      it 'has Location Param' do
        expect(requestable.aeon_basic_params.key?(:Location)).to be true
        expect(requestable.aeon_basic_params[:Location]).to eq(requestable.holding.first.last['location_code'])
      end
    end

    describe '#aeon_request_url' do
      it 'beings with Aeon GFA base' do
        expect(requestable.aeon_request_url(request.ctx)).to match(/^#{Requests.config[:aeon_base]}/)
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('ReCAP - Rare Books Off-Site Storage')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'A requestable item from Forrestal Annex with no item data' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_no_items) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    # rubocop:disable RSpec/MultipleExpectations
    describe 'requestable with no items ' do
      it 'does not have item data' do
        expect(requestable.item_data?).to be false
        expect(requestable.pickup_location_id).to eq ""
        expect(requestable.pickup_location_code).to eq ""
        expect(requestable.item_type).to eq ""
        expect(requestable.enum_value).to eq ""
        expect(requestable.cron_value).to eq ""
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Forrestal Annex - Princeton Collection')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'On Order materials' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_on_order) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe 'with a status of on_order ' do
      it 'is on_order' do
        expect(requestable.on_order?).to be true
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  context 'Pending Order materials' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_pending) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe 'with a status of pending orders' do
      it 'is treated like on order items' do
        expect(requestable.on_order?).to be true
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('ReCAP - Marquand Library use only')
      end
    end

    describe '#libcal_url' do
      it "is available for appointment" do
        expect(requestable.libcal_url).to be_nil
      end
    end
  end

  # user authentication tests
  context 'When a princeton user with NetID visits the site' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9999800',
        user: user,
        user_barcode: '111222333'
      }
    end
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '# offsite requestable' do
      # TODO: Activate test when campus has re-opened
      it "has recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "has recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
    end

    let(:request_charged) { FactoryGirl.build(:request_with_items_charged) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding['1594698'] } }
    let(:requestable_charged) { requestable_holding.first }

    describe '# checked-out requestable' do
      # TODO: Remove when campus has re-opened
      it "does not have borrow direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have borrow direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be true
      end

      # TODO: Remove when campus has re-opened
      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be true
      end

      # TODO: Remove when campus has re-opened
      it "does not have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be true
      end
    end

    let(:request_missing) { FactoryGirl.build(:request_missing_item) }
    let(:requestable_missing) { request_missing.requestable.first }

    describe '# missing requestable' do
      # TODO: Remove when campus has re-opened
      it "does not have borrow direct request service available" do
        expect(requestable_missing.services.include?('bd')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have borrow direct request service available" do
        expect(requestable_missing.services.include?('bd')).to be true
      end

      # TODO: Remove when campus has re-opened
      it "does not have ILL request service available" do
        expect(requestable_missing.services.include?('ill')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have ILL request service available" do
        expect(requestable_missing.services.include?('ill')).to be true
      end

      it "does not have recall request service available" do
        expect(requestable_missing.services.include?('recall')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryGirl.build(:aeon_mudd) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '# reading_room requestable' do
      it "has Aeon request service available" do
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
    let(:params) do
      {
        system_id: '9999800',
        user: user,
        user_barcode: '111222333'
      }
    end
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#requestable' do
      # TODO: Activate test when campus has re-opened
      it "has recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "has recap edd request service available" do
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
      # TODO: Remove when campus has re-opened
      it "does not have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be true
      end

      # Barcode users should NOT have the following privileges ...

      it "does not have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryGirl.build(:aeon_mudd_barcode_patron) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '#reading room requestable' do
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end
  end

  context 'When an access only user visits the site' do
    let(:user) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) do
      {
        system_id: '9999800',
        user: user,
        user_barcode: '111222333'
      }
    end
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#recap requestable' do
      # TODO: Remove when campus has re-opened
      it "does not have recap request service available during campus closure" do
        expect(requestable.services.include?('recap')).to be false
      end
      # TODO: Activate test when campus has re-opened
      xit "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end

      it "does not have recap edd request service available" do
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
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end

    # Barcode users should NOT have the following privileges ...
    let(:request_charged) { FactoryGirl.build(:request_with_items_charged_unauthenticated_patron) }
    let(:requestable_charged) { request_charged.requestable.first }

    describe '#checked-out requestable' do
      it "does not have recall request service available" do
        expect(requestable_charged.services.include?('recall')).to be false
      end

      it "does not have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      it "does not have ILL request service available" do
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
        stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=53360890")
          .to_return(status: 200, body: '[]')
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('QX')
      end
    end

    describe '#etas_limited_access' do
      it 'is not restricted' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=53360890")
          .to_return(status: 200, body: '[]')
        expect(requestable.etas_limited_access). to be_falsey
      end
    end
  end

  context 'A SCSB Item with no oclc number' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_no_oclc) }
    let(:requestable) { request.requestable.first }

    describe '#etas_limited_access' do
      it 'is not restricted' do
        expect(requestable.etas_limited_access). to be_falsey
      end
    end
  end

  context 'A SCSB Item from a location with a pickup restrictions' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_ar) }
    let(:requestable) { request.requestable.first }
    describe '#pickup_locations' do
      it 'has a single pickup location' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=29065769")
          .to_return(status: 200, body: '[]')
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('PJ')
        expect(requestable.item["use_statement"]).to eq('In Library Use')
        expect(requestable.pick_up?).to be_falsey
      end
    end
  end
  context 'A SCSB Item from a location with no pickup restrictions' do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_scsb_mr) }
    let(:requestable) { request.requestable.first }
    describe '#pickup_locations' do
      it 'has a single pickup location' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=17322905")
          .to_return(status: 200, body: '[{"id":null,"oclc_number":"17322905","bibid":"1029088","status":"ALLOW","origin":"CUL"}, {"id":null,"oclc_number":"17322905","bibid":"1029088","status":"DENY","origin":"CUL"}]')
        expect(requestable.pickup_locations.size).to eq(1)
        expect(requestable.pickup_locations.first[:gfa_pickup]).to eq('PK')
        expect(requestable.pick_up?).to be_falsey
      end
    end
  end

  describe "#will_submit_via_form?" do
    let(:location) { {} }
    let(:item_data) {}
    let(:requestable) { described_class.new(bib: {}, holding: [{ 1 => { 'call_number_browse': 'abc' } }], item: item_data, location: location, user_barcode: '111222333') }
    let(:services) { [] }
    let(:on_reserve) { false }
    let(:traceable) { false }
    let(:on_order) { false }
    let(:in_process) { false }
    let(:aeon) { false }
    let(:charged) { false }

    before do
      allow(requestable).to receive(:services).and_return(services)
      allow(requestable).to receive(:on_reserve?).and_return(on_reserve)
      allow(requestable).to receive(:on_order?).and_return(on_order)
      allow(requestable).to receive(:in_process?).and_return(in_process)
      allow(requestable).to receive(:aeon?).and_return(aeon)
      allow(requestable).to receive(:traceable?).and_return(traceable)
      allow(requestable).to receive(:charged?).and_return(charged)
    end

    context "no services" do
      it 'does not submit via form' do
        expect(requestable.will_submit_via_form?).to be_falsey
      end
    end

    context "on_reserve" do
      let(:on_reserve) { true }
      it 'does not submit via form' do
        expect(requestable.will_submit_via_form?).to be_falsey
      end
    end

    context "charged" do
      let(:charged) { true }
      it 'does not submit via form' do
        expect(requestable.will_submit_via_form?).to be_falsey
      end
    end

    context "traceable?" do
      let(:traceable) { true }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "on_order" do
      let(:on_order) { true }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "in_process" do
      let(:in_process) { true }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "aeon" do
      let(:aeon) { true }
      it 'does not submit via form' do
        expect(requestable.will_submit_via_form?).to be_falsey
      end
    end

    context "item_data and on_shelf" do
      let(:item_data) { { id: '123' } }
      let(:services) { ['on_shelf'] }
      let(:location) { { circulates: true, library: { code: 'firestone' } } }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "item_data and annexa" do
      let(:item_data) { { id: '123' } }
      let(:services) { ['annexa'] }
      let(:location) { { circulates: true, library: { code: 'annexa' } } }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "item_data and recap" do
      let(:item_data) { { id: '123' } }
      let(:services) { ['recap'] }
      let(:location) { { circulates: true, library: { code: 'recap' } }.with_indifferent_access }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "item_data and on_shelf_edd" do
      let(:item_data) { { abc: '123' } }
      let(:services) { ['on_shelf_edd'] }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end

    context "item_data and recap_edd" do
      let(:item_data) { { id: '123' } }
      let(:services) { ['recap_edd'] }
      let(:location) { { circulates: true, library: { code: 'recap' } }.with_indifferent_access }
      it 'does submit via form' do
        expect(requestable.will_submit_via_form?).to be_truthy
      end
    end
  end
end
