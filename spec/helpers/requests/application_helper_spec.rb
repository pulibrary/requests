require 'spec_helper'
require './app/models/requests/request.rb'

RSpec.describe Requests::ApplicationHelper, type: :helper,
                                            vcr: { cassette_name: 'request_models', record: :new_episodes } do

  let(:user) { FactoryGirl.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777",
      "university_id" => "9999999", "patron_group" => "staff", "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user: user, session: {}, patron: valid_patron)
  end

  describe '#isbn_string' do
    let(:isbns) do
      [
        '9780544343757',
        '179758877'
      ]
    end
    let(:isbn_string) { helper.isbn_string(isbns) }
    it 'returns a list of formatted isbns' do
      expect(isbn_string).to eq('9780544343757,179758877')
    end
  end

  describe '#submit_disabled' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9981794023506421',
        mfhd: '22237592660006421',
        patron: patron
      }
    end
    let(:request_with_items_on_reserve) { Requests::Request.new(params) }
    let(:requestable_list) { request_with_items_on_reserve.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }

    it 'returns a boolean to disable/enable submit' do
      expect(submit_button_disabled).to be_truthy
    end

    # temporary for #348
    context "Firestone Classics Collection (Clas)" do
      let(:params) do
        {
          system_id: '9992220243506421',
          mfhd: '22251138630006421',
          patron: patron
        }
      end
      it 'returns a boolean to enable submit for logged in user' do
        assign(:user, user)
        expect(submit_button_disabled).to be_falsey
      end

      it 'returns a boolean to disable submit for guest' do
        assign(:user, nil)
        expect(submit_button_disabled).to be_truthy
      end
    end

    describe 'lewis library' do
      let(:params) do
        {
          system_id: '9938488723506421',
          mfhd: '22205589810006421',
          patron: patron
        }
      end
      it 'lewis is a submitable request' do
        assign(:user, user)
        expect(submit_button_disabled).to be false
      end
    end
  end

  describe 'firestone pick_up_choices' do
    let(:params) do
      {
        system_id: '994916543506421',
        mfhd: '22113812540006421',
        patron: patron
      }
    end
    let(:default_pick_ups) do
      [{ label: "Firestone Library", gfa_pickup: "PA", staff_only: false }, { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }, { label: "East Asian Library", gfa_pickup: "PL", staff_only: false }, { label: "Lewis Library", gfa_pickup: "PN", staff_only: false }, { label: "Marquand Library of Art and Archaeology", gfa_pickup: "PJ", staff_only: false }, { label: "Mendel Music Library", gfa_pickup: "PK", staff_only: false }, { label: "Plasma Physics Library", gfa_pickup: "PQ", staff_only: false }, { label: "Stokes Library", gfa_pickup: "PM", staff_only: false }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::RequestDecorator.new(Requests::Request.new(params), self) }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }
    it 'lewis is a submitable request' do
      choices = helper.pick_up_choices(lewis_request_with_multiple_requestable.requestable.last, default_pick_ups)
      expect(choices).to eq("<div id=\"fields-print__23113812530006421\" class=\"collapse request--print\"><div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div><div id=\"fields-print__23113812530006421_card\" class=\"card card-body bg-light\"><input type=\"hidden\" name=\"requestable[][pick_up]\" id=\"requestable__pick_up\" value=\"{&quot;pick_up&quot;:&quot;PN&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\" class=\"single-pick-up-hidden\" /><label class=\"single-pick-up\" style=\"\" for=\"requestable__pick_up\">Pick-up location: Lewis Library</label></div></div>")
    end
  end

  describe 'multiple delivery options' do
    let(:params) do
      {
        system_id: '994264203506421',
        mfhd: '2284684460006421',
        patron: patron
      }
    end
    let(:default_pick_ups) do
      [{ label: "Firestone Library", gfa_pickup: "PA", staff_only: false }, { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }, { label: "East Asian Library", gfa_pickup: "PL", staff_only: false }, { label: "Lewis Library", gfa_pickup: "PN", staff_only: false }, { label: "Marquand Library of Art and Archaeology", gfa_pickup: "PJ", staff_only: false }, { label: "Mendel Music Library", gfa_pickup: "PK", staff_only: false }, { label: "Plasma Physics Library", gfa_pickup: "PQ", staff_only: false }, { label: "Stokes Library", gfa_pickup: "PM", staff_only: false }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::RequestDecorator.new(Requests::Request.new(params), self) }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }
    it 'lewis is a submitable request' do
      choices = helper.pick_up_choices(lewis_request_with_multiple_requestable.requestable.last, default_pick_ups)
      expect(choices).to eq("<div id=\"fields-print__2384684450006421\" class=\"collapse request--print\"><ul class=\"service-list\"><li class=\"service-item\">Item offsite at Forrestal Annex. Requests for pick-up typically take 1-2 business days to process.</li></ul><div id=\"fields-print__2384684450006421_card\" class=\"card card-body bg-light\"><select name=\"requestable[][pick_up]\" id=\"requestable__pick_up\"><option value=\"\">Select a Delivery Location</option><option value=\"{&quot;pick_up&quot;:&quot;PA&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Firestone Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;PW&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Architecture Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;PL&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">East Asian Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;PN&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Lewis Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;PK&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Mendel Music Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;PM&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Stokes Library</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QA&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Firestone Library, Resource Sharing (Staff Only)</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QT&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Technical Services 693 (Staff Only)</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QC&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Technical Services HMT (Staff Only)</option></select></div></div>")
    end
  end

  describe '#suppress_login' do
    let(:unauthenticated_patron) { FactoryGirl.build(:unauthenticated_patron) }
    let(:patron) { Requests::Patron.new(user: unauthenticated_patron, session: {}) }
    let(:params) do
      {
        system_id: '9973529363506421',
        mfhd: '22111313060006421',
        patron: patron
      }
    end
    let(:aeon_only_request) { Requests::RequestDecorator.new(Requests::Request.new(params), nil) }
    let(:login_suppressed) { helper.suppress_login(aeon_only_request) }

    it 'returns a boolean to disable/enable submit' do
      expect(login_suppressed).to be true
    end
  end

  describe '#hidden_fields_mfhd' do
    let(:mfhd) do
      {
        "location" => "ReCAP - Use in Firestone Microforms only",
        "library" => "ReCAP",
        "location_code" => "rcppf",
        "copy_number" => "1",
        "call_number" => "MICROFILM S00534",
        "call_number_browse" => "MICROFILM S00534",
        "location_has" => [
          "No. 22 (Mar. 10/17 1969)-no. 47 (Oct. 6, 1969)",
          "No. 22-47 on reel with no. 1-21 of the earlier title."
        ]
      }
    end

    it 'generates the <input type="hidden"> element markup using MFHD values' do
      expect(helper.hidden_fields_mfhd(mfhd)).to eq \
        "<input type=\"hidden\" name=\"mfhd[][call_number]\" id=\"mfhd__call_number\" value=\"MICROFILM S00534\" /><input type=\"hidden\" name=\"mfhd[][location]\" id=\"mfhd__location\" value=\"ReCAP - Use in Firestone Microforms only\" /><input type=\"hidden\" name=\"mfhd[][library]\" id=\"mfhd__library\" value=\"ReCAP\" />"
    end

    context 'when the MFHD is nil' do
      it 'generates no markup' do
        expect(helper.hidden_fields_mfhd(nil)).to be_empty
      end
    end
  end

  describe "#show_service_options" do
    let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
    let(:request) { instance_double(Requests::Request, ctx: solr_context) }
    let(:solr_context) { instance_double(Requests::SolrOpenUrlContext) }
    context "lewis library" do
      let(:stubbed_questions) do
        { services: ['on_shelf'], charged?: false, aeon?: false,
          on_shelf?: true, lewis?: true,
          location: { library: { label: "Lewis Library" } } }
      end
      it 'a message for lewis' do
        expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq \
          "<div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div>"
      end
    end

    context "lewis library charged" do
      let(:stubbed_questions) { { services: ['lewis'], charged?: true, aeon?: false, on_shelf?: false, ask_me?: false } }
      it 'a message for lewis charged' do
        expect(helper).to receive(:render).with(partial: 'checked_out_options', locals: { requestable: requestable }).and_return('partial rendered')
        expect(helper.show_service_options(requestable, 'acb')).to eq "partial rendered"
      end
    end

    context "on shelf not traceable" do
      let(:stubbed_questions) do
        { services: ['on_shelf'], charged?: false, aeon?: false,
          voyager_managed?: false, ask_me?: false, on_shelf?: true,
          map_url: 'map_abc', traceable?: false, location: { library: { label: 'abc' } } }
      end
      it 'a link to a map' do
        assign(:request, request)
        # temporary change no maps everything is pageable
        # expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><a href=\"map_abc\">Where to find it</a></div>"
        expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div>"
      end
    end

    context "on shelf traceable" do
      let(:stubbed_questions) do
        { services: ['on_shelf'], charged?: false, aeon?: false,
          voyager_managed?: false, ask_me?: false, on_shelf?: true,
          map_url: 'map_abc', traceable?: true, location: { library: { label: 'abc' } } }
      end
      it 'a link to a map' do
        assign(:request, request)
        # temporary change no maps everything is pageable
        # expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><a href=\"map_abc\">Where to find it</a><div class=\"service-item\">Trace a Missing Item. Library staff will search for this item and contact you with an outcome.</div></div>"
        expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div>"
      end
    end

    context "no services" do
      let(:stubbed_questions) { { services: [], preferred_request_id: '123', title: 'My Title', item: nil } }
      it 'a message for lewis' do
        expect(helper.show_service_options(requestable, 'acb')).to eq \
          "<div class=\"sr-only\">My Title  Item is not requestable.</div>" \
          "<div class=\"service-item\" aria-hidden=\"true\">Item is not requestable.</div>"
      end
    end

    context "no services enum" do
      let(:stubbed_questions) { { services: [], preferred_request_id: '123', title: 'My Title', item: { enum_display: "abc123" } } }
      it 'a message for lewis' do
        expect(helper.show_service_options(requestable, 'acb')).to eq \
          "<div class=\"sr-only\">My Title abc123 Item is not requestable.</div>" \
          "<div class=\"service-item\" aria-hidden=\"true\">Item is not requestable.</div>"
      end
    end
  end

  describe "#preferred_request_content_tag" do
    let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
    let(:default_pick_ups) { [{ label: 'place', gfa_pickup: 'xx', staff_only: false, pick_up_location_code: 'firestone' }] }
    let(:card_div) { '<div id="fields-print__abc123_card" class="card card-body bg-light">' }

    context "no services" do
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: false, recap?: false, annex?: false, pick_up_locations: nil, charged?: false, on_shelf?: false, location: { "library" => default_pick_ups[0] }, borrow_direct?: false, ill_eligible?: false } }
      it 'shows default pick-up location' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: place</label></div>'
      end
    end

    context "no services multiple defaults" do
      let(:default_pick_ups) { [{ label: 'place', gfa_pickup: 'xx', staff_only: false, pick_up_location_code: 'firestone' }, { label: 'place two', gfa_pickup: 'xz', staff_only: false }] }
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: false, recap?: false, annex?: false, pick_up_locations: nil, charged?: false, on_shelf?: false, location: { "library" => default_pick_ups[0] }, borrow_direct?: false, ill_eligible?: false } }
      it 'shows default pick-up location' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: place</label></div>'
        # temporary change on pageable to one location
        # card_div + '<select name="requestable[][pick_up]" id="requestable__pick_up"><option value="">Select a Delivery Location</option><option value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}">place</option>' + "\n" + '<option value="xz">place two</option></select></div>'
      end
    end

    context "no services and charged" do
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: false, recap?: false, annex?: false, pick_up_locations: nil, charged?: true, on_shelf?: false, location: { "library" => default_pick_ups[0] }, borrow_direct?: false, ill_eligible?: false } }
      it 'shows default pick-up location hidden' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="margin-top:10px;" for="requestable__pick_up">Pick-up location: place</label></div>'
      end
    end

    context "no services pick-up locations" do
      let(:locations) { [{ label: 'another place', gfa_pickup: 'yy', staff_only: false }] }
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: false, pick_up_locations: locations, charged?: false, location: { "library" => default_pick_ups[0] }, borrow_direct?: false, ill_eligible?: false } }
      it 'shows the pick-up location' do
        pending "Always uses holding location"
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: another place</label></div>'
      end
    end

    context "no services pending at a location" do
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: true, on_shelf?: false, delivery_location_label: "cool library", delivery_location_code: "xx", pick_up_location_code: 'firestone', charged?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'shows the holding location' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: cool library</label></div>'
      end
    end

    context "borrow direct" do
      let(:holding_location) { { holding_library: { label: 'cool library', code: 'xx' } } }
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: true, on_shelf?: false, location: holding_location, charged?: false, borrow_direct?: true, ill_eligible?: false } }
      it 'shows the holding location' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: place</label></div>'
      end
    end

    context "interlibrary loan" do
      let(:holding_location) { { holding_library: { label: 'cool library', code: 'xx' } } }
      let(:stubbed_questions) { { services: [], preferred_request_id: 'abc123', pending?: true, on_shelf?: false, location: holding_location, charged?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'shows the holding location' do
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          card_div + '<input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="{&quot;pick_up&quot;:&quot;xx&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: place</label></div>'
      end
    end

    context "recap_edd" do
      let(:stubbed_questions) { { services: ['recap_edd'], preferred_request_id: 'abc123', pending?: false, pick_up_locations: locations, charged?: false, location: { "library" => default_pick_ups[0] } } }
      let(:locations) { [{ label: 'another place', gfa_pickup: 'yy', staff_only: false }] }
      it 'a message for lewis' do
        pending "Always uses holding location"
        expect(helper.preferred_request_content_tag(requestable, default_pick_ups)).to eq \
          '<div id="fields-print__abc123" class="card card-body bg-light collapse request--print"><input type="hidden" name="requestable[][pick_up]" id="requestable__pick_up" value="" class="single-pick-up-hidden" /><label class="single-pick-up" style="" for="requestable__pick_up">Pick-up location: another place</label></div>'
      end
    end
  end

  describe "#hidden_fields_item" do
    let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }

    context "no services" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb" }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to eq '<input type="hidden" name="requestable[][bibid]" id="requestable_bibid_aaabbb" value="abc123" /><input type="hidden" name="requestable[][mfhd]" id="requestable_mfhd_aaabbb" value="key1" /><input type="hidden" name="requestable[][location_code]" id="requestable_location_aaabbb" value="" /><input type="hidden" name="requestable[][item_id]" id="requestable_item_id_aaabbb" value="aaabbb" /><input type="hidden" name="requestable[][copy_number]" id="requestable_copy_number_aaabbb" value="" /><input type="hidden" name="requestable[][status]" id="requestable_status_aaabbb" value="" />'
      end
    end

    context "with item location" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb", 'location' => 'place' }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: 'place' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][location_code]" id="requestable_location_aaabbb" value="place" />'
      end
    end

    context "with item barcode" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb", 'barcode' => '111222333' }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][barcode]" id="requestable_barcode_aaabbb" value="111222333" />'
      end
    end

    context "with item enum" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb", 'enum_display' => 'vvv' }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][enum]" id="requestable_enum_aaabbb" value="vvv" />'
      end
    end

    context "with item enumeration" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { id: "aaabbb", enumeration: 'sss', copy_number: '0', enum_display: 'v.2' }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][enum]" id="requestable_enum_aaabbb" value="sss" />'
      end
      it 'hides the enum display if the copy number is zero (0)' do
        expect(helper.enum_copy_display(requestable.item)).to eq("v.2 sss")
      end
    end

    context "with item scsb_status" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb", 'scsb_status' => 'status' }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][scsb_status]" id="requestable_scsb_status_aaabbb" value="status" />'
      end
    end

    context "with holding call number" do
      let(:holding) { { "1594697" => { "location" => "Firestone Library", "library" => "Firestone Library", "location_code" => "f", "copy_number" => "0", "call_number" => "6251.9765", "call_number_browse" => "6251.9765" } } }
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb" }, holding: holding, location: { code: 'location_code' }, scsb?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to include '<input type="hidden" name="requestable[][call_number]" id="requestable_call_number_aaabbb" value="6251.9765" />'
      end
    end

    context "scsb item" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: { 'id' => "aaabbb" }, holding: { key1: 'value1' }, location: { code: 'location_code' }, scsb?: true, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'shows hidden fields' do
        expect(helper.hidden_fields_item(requestable)).to eq '<input type="hidden" name="requestable[][bibid]" id="requestable_bibid_aaabbb" value="abc123" /><input type="hidden" name="requestable[][mfhd]" id="requestable_mfhd_aaabbb" value="key1" /><input type="hidden" name="requestable[][location_code]" id="requestable_location_aaabbb" value="" /><input type="hidden" name="requestable[][item_id]" id="requestable_item_id_aaabbb" value="aaabbb" /><input type="hidden" name="requestable[][copy_number]" id="requestable_copy_number_aaabbb" value="" /><input type="hidden" name="requestable[][status]" id="requestable_status_aaabbb" value="" /><input type="hidden" name="requestable[][cgc]" id="requestable_cgc_aaabbb" value="" /><input type="hidden" name="requestable[][cc]" id="requestable_collection_code_aaabbb" value="" /><input type="hidden" name="requestable[][use_statement]" id="requestable_use_statement_aaabbb" value="" />'
      end
    end
  end
end
