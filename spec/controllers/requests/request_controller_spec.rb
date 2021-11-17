require 'spec_helper'
require "mail"

describe Requests::RequestController, type: :controller, vcr: { cassette_name: 'request_controller', record: :none } do
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }
  let(:user) { FactoryBot.create(:user) }

  routes { Requests::Engine.routes }

  describe 'POST #generate' do
    it 'handles access patron params when the user form is posted' do
      post :generate, params: { request: { username: 'foobar', email: 'foo@bar.com' },
                                source: 'pulsearch',
                                system_id: '9963773693506421', mfhd: '22239658680006421' }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #generate' do
    context "An campus authorized user" do
      before do
        sign_in(user)
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_response, headers: {})
      end

      it 'sets the current request mode to trace when supplied' do
        stub_scsb_availability(bib_id: "9996764833506421", institution_id: "PUL", barcode: '32101099103457')
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9996764833506421',
          mfhd: '2275983490006421',
          mode: "trace"
        }
        expect(assigns(:mode)).to eq('trace')
      end
      it 'uses the default request mode and does not set a flash' do
        stub_scsb_availability(bib_id: "9996764833506421", institution_id: "PUL", barcode: '32101099103457')
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9996764833506421',
          mfhd: '2275983490006421'
        }
        expect(flash.now[:notice]).to be_blank
        expect(assigns(:mode)).to eq('standard')
      end
      it 'redirects you when a thesis record is requested' do
        stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/dsp01rr1720547/raw")
          .to_return(status: 200, body: fixture('/dsp01rr1720547.json'), headers: {})

        get :generate, params: {
          source: 'pulsearch',
          system_id: 'dsp01rr1720547',
          mfhd: 'thesis'
        }
        expect(response.status).to eq(302)
      end
      it 'redirects you when a single aeon record is requested' do
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9995768803506421',
          mfhd: '22497016220006421'
        }
        expect(response.status).to eq(302)
      end

      it 'does not redirect you when multiple aeon records are requested' do
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9995768803506421',
          mfhd: '2298692650006421'
        }
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'POST #submit' do
    let(:user_info) do
      {
        "patron_id" => "12345",
        "patron_group" => "staff",
        "user_name" => "Foo Request",
        "user_barcode" => "22101007797777",
        "email" => "foo@princeton.edu",
        "source" => "pulsearch"
      }.with_indifferent_access
    end
    let(:requestable) do
      [
        {
          "selected" => "true",
          "bibid" => "9995904203506421",
          "mfhd" => "2297676790006421",
          "call_number" => "PN1995.9.A76 P7613 2015",
          "location_code" => "rcppj",
          "item_id" => "7391704",
          "barcode" => "32101098797010",
          "copy_number" => "0",
          "status" => "Not Charged",
          "pick_up" => "",
          "type" => "recap",
          "edd_art_title" => "test",
          "edd_start_page" => "1",
          "edd_end_page" => "1",
          "edd_volume_number" => "1",
          "edd_issue" => "1",
          "edd_author" => "",
          "edd_note" => ""
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9995904203506421"
      }.with_indifferent_access
    end

    # rubocop:disable RSpec/VerifiedDoubles
    let(:mail_message) { double(::Mail::Message) }
    # rubocop:enable RSpec/VerifiedDoubles

    before do
      sign_in(user)
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      without_partial_double_verification do
        allow(mail_message).to receive(:deliver_now).and_return(nil)
      end
    end

    context "recap requestable" do
      let(:recap) { instance_double(Requests::Submissions::Recap, errors: [], handle: {}, service_type: 'recap_edd', success_message: 'success!') }
      it 'contacts recap and sends email' do
        requestable.first["library_code"] = "recap"
        requestable.first["delivery_mode_7391704"] = "edd"
        expect(Requests::Submissions::Recap).to receive(:new).with(anything, service_type: 'recap_edd').and_return(recap)
        expect(Requests::RequestMailer).to receive(:send).with("recap_edd_confirmation", anything).and_return(mail_message)
        expect(Requests::RequestMailer).not_to receive(:send).with("recap_email", anything)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "borrow direct requestable" do
      let(:borrow_direct) { instance_double(Requests::Submissions::BorrowDirect, errors: [], handle: true, sent: [{ request_number: '123' }], handled_by: "borrow_direct", service_type: 'bd', success_message: 'success!') }
      it 'contacts borrow direct and sends no emails ' do
        requestable.first["type"] = "bd"
        requestable.first["pick_up"] = { pick_up: "PA", pick_up_location_code: "firestone" }.to_json
        requestable.first["bd"] = { query_params: "abc" }
        expect(Requests::RequestMailer).not_to receive(:send)
        expect(Requests::Submissions::BorrowDirect).to receive(:new).and_return(borrow_direct)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "recall requestable and sends recall_email" do
      let(:recal) { instance_double(Requests::Submissions::Recall, errors: [], handle: {}, service_type: 'recall', success_message: 'success!') }
      it 'contacts recall and sends email' do
        requestable.first["type"] = "recall"
        requestable.first["pick_up"] = { pick_up: "PA", pick_up_location_code: "firestone" }.to_json
        expect(Requests::Submissions::Recall).to receive(:new).and_return(recal)
        expect(Requests::RequestMailer).to receive(:send).with("recall_email", anything).and_return(mail_message)
        expect(Requests::RequestMailer).not_to receive(:send).with("recall_confirmation", anything)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "recap_no_items requestable" do
      let(:generic) { instance_double(Requests::Submissions::Generic, errors: [], handle: {}, service_type: 'recap_no_items', success_message: 'success!') }
      it 'sends email and confirmation email' do
        requestable.first["type"] = "recap_no_items"
        requestable.first["pick_up"] = { pick_up: "PA", pick_up_location_code: "firestone" }.to_json
        expect(Requests::Submissions::Generic).to receive(:new).with(anything, service_type: 'recap_no_items').and_return(generic)
        expect(Requests::RequestMailer).to receive(:send).with("recap_no_items_email", anything).and_return(mail_message)
        expect(Requests::RequestMailer).to receive(:send).with("recap_no_items_confirmation", anything).and_return(mail_message)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "invalid submission" do
      it 'returns an error' do
        requestable.first.delete("edd_art_title")
        requestable.first["edd_art_title"] = ""
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
        expect(response.status).to eq(200)
        expect(flash[:error]).to eq('We were unable to process your request. Correct the highlighted errors.')
      end
    end

    context "service error" do
      it 'returns and error' do
        requestable.first["library_code"] = "recap"
        requestable.first["delivery_mode_7391704"] = "edd"
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
        expect(response.status).to eq(200)
        expect(flash[:error]).to eq("There was a problem with this request which Library staff need to investigate. You'll be notified once it's resolved and requested for you.")
      end
    end
  end

  describe 'POST #recall_pick_ups' do
    let(:user_info) do
      {
        "patron_id" => "12345",
        "patron_group" => "staff"
      }.with_indifferent_access
    end
    let(:requestable) do
      [
        {
          "item_id" => "23173625050006421"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "994620293506421"
      }.with_indifferent_access
    end
    let(:responses) do
      {
        error: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="N"><note type="error">You have already placed a request for this item.</note></recall></response>',
        success: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="Y"><pick_up-locations usage="Mandatory"><pick_up-location code="299" default="Y">.Firestone Library Circulation Desk</pick_up-location><pick_up-location code="533" default="N">693 TSD Circulation Desk</pick_up-location><pick_up-location code="356" default="N">Architecture Library Circulation Desk</pick_up-location><pick_up-location code="333" default="N">Donald E. Stokes Library, Wallace Hall, Circulation Desk</pick_up-location><pick_up-location code="303" default="N">' \
          'East Asian Library Circulation Desk</pick_up-location><pick_up-location code="345" default="N">Engineering Library Circulation Desk</pick_up-location><pick_up-location code="440" default="N">Firestone Microforms Services</pick_up-location><pick_up-location code="293" default="N">Annex A Circulation Desk</pick_up-location><pick_up-location code="395" default="N">Interlibrary Services Circulation Desk</pick_up-location><pick_up-location code="489" default="N">Lewis Library Circulation Desk</pick_up-location><pick_up-location code="321" default="N">Marquand Library Circulation Desk</pick_up-location>' \
          '<pick_up-location code="309" default="N">Mendel Music Library Circulation Desk</pick_up-location><pick_up-location code="312" default="N">Harold P. Furth Plasma Physics Library Circulation Desk</pick_up-location><pick_up-location code="400" default="N">Pre-Bindery Circulation Desk</pick_up-location><pick_up-location code="394" default="N">Preservation Office Circulation</pick_up-location><pick_up-location code="427" default="N">RECAP Circulation</pick_up-location><pick_up-location code="315" default="N">Rare Books and Special Collections Circulation Desk</pick_up-location><pick_up-location code="306" default="N">' \
          'Seeley G. Mudd Library Circulation Desk</pick_up-location><pick_up-location code="353" default="N">Technical Services Circulation</pick_up-location><pick_up-location code="359" default="N">Video Collection: Video Circulation Desk</pick_up-location><pick_up-location code="437" default="N">Borrow Direct Service. Princeton University Library</pick_up-location><pick_up-location code="439" default="N">zDatabase Maintenance</pick_up-location>"    </pick_up-locations>"    <dbkey code="" usage="Mandatory">Local Database</dbkey>"    <instructions usage="read-only">Please select an item.</instructions><last-interest-date usage="Mandatory">2017-02-11</last-interest-date><comment max_len="100" usage="Optional"/></recall></response>'
      }
    end
    before do
      stub_url = Requests::Config[:voyager_api_base] + "/vxws/record/" + bib['id'] +
                 "/items/" + requestable[0]['item_id'] +
                 "/recall?patron=" + user_info['patron_id'] +
                 "&patron_group=" + user_info['patron_group'] +
                 "&patron_homedb=" + URI.escape('1@DB')
      stub_request(:get, stub_url)
        .with(headers: { 'Accept' => '*/*' })
        .to_return(status: 201, body: responses[:success], headers: {})
    end
    it 'returns a pick-up json response' do
      post :recall_pickups, params: { "request" => user_info,
                                      "requestable" => requestable,
                                      "bib" => bib }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #index' do
    it 'redirects to the root url' do
      get :index
      expect(response).to redirect_to("/")
    end
  end
end
