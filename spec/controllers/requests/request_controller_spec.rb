require 'spec_helper'

describe Requests::RequestController, type: :controller, vcr: { cassette_name: 'request_controller', record: :new_episodes } do
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }
  let(:user) { FactoryGirl.create(:user) }

  routes { Requests::Engine.routes }

  describe 'POST #generate' do
    it 'handles access patron params when the user form is posted' do
      post :generate, params: { request: { username: 'foobar', email: 'foo@bar.com' },
                                source: 'pulsearch',
                                system_id: '6377369' }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #generate' do
    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'sets the current request mode to trace when supplied' do
      get :generate, params: {
        source: 'pulsearch',
        system_id: '9676483',
        mode: "trace"
      }
      expect(assigns(:mode)).to eq('trace')
    end
    it 'uses the default request mode' do
      get :generate, params: {
        source: 'pulsearch',
        system_id: '9676483'
      }
      expect(assigns(:mode)).to eq('standard')
    end
    it 'redirects you when a thesis record is requested' do
      get :generate, params: {
        source: 'pulsearch',
        system_id: 'dsp01rr1720547'
      }
      expect(response.status).to eq(302)
    end
  end

  describe 'POST #recall_pickups' do
    let(:user_info) do
      {
        "patron_id" => "12345",
        "patron_group" => "staff"
      }.with_indifferent_access
    end
    let(:requestable) do
      [
        {
          "item_id" => "552328"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "462029"
      }.with_indifferent_access
    end
    let(:responses) do
      {
        error: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="N"><note type="error">You have already placed a request for this item.</note></recall></response>',
        success: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="Y"><pickup-locations usage="Mandatory"><pickup-location code="299" default="Y">.Firestone Library Circulation Desk</pickup-location><pickup-location code="533" default="N">693 TSD Circulation Desk</pickup-location><pickup-location code="356" default="N">Architecture Library Circulation Desk</pickup-location><pickup-location code="333" default="N">Donald E. Stokes Library, Wallace Hall, Circulation Desk</pickup-location><pickup-location code="303" default="N">East Asian Library Circulation Desk</pickup-location><pickup-location code="345" default="N">Engineering Library Circulation Desk</pickup-location><pickup-location code="440" default="N">Firestone Microforms Services</pickup-location><pickup-location code="293" default="N">Annex A Circulation Desk</pickup-location><pickup-location code="395" default="N">Interlibrary Services Circulation Desk</pickup-location><pickup-location code="489" default="N">Lewis Library Circulation Desk</pickup-location><pickup-location code="321" default="N">Marquand Library Circulation Desk</pickup-location><pickup-location code="309" default="N">Mendel Music Library Circulation Desk</pickup-location><pickup-location code="312" default="N">Harold P. Furth Plasma Physics Library Circulation Desk</pickup-location><pickup-location code="400" default="N">Pre-Bindery Circulation Desk</pickup-location><pickup-location code="394" default="N">Preservation Office Circulation</pickup-location><pickup-location code="427" default="N">RECAP Circulation</pickup-location><pickup-location code="315" default="N">Rare Books and Special Collections Circulation Desk</pickup-location><pickup-location code="306" default="N">Seeley G. Mudd Library Circulation Desk</pickup-location><pickup-location code="353" default="N">Technical Services Circulation</pickup-location><pickup-location code="359" default="N">Video Collection: Video Circulation Desk</pickup-location><pickup-location code="437" default="N">Borrow Direct Service. Princeton University Library</pickup-location><pickup-location code="439" default="N">zDatabase Maintenance</pickup-location>"    </pickup-locations>"    <dbkey code="***REMOVED***" usage="Mandatory">Local Database</dbkey>"    <instructions usage="read-only">Please select an item.</instructions><last-interest-date usage="Mandatory">2017-02-11</last-interest-date><comment max_len="100" usage="Optional"/></recall></response>'
      }
    end
    before do
      stub_url = Requests.config[:voyager_api_base] + "/vxws/record/" + bib['id'] +
                 "/items/" + requestable[0]['item_id'] +
                 "/recall?patron=" + user_info['patron_id'] +
                 "&patron_group=" + user_info['patron_group'] +
                 "&patron_homedb=" + URI.escape('1@DB')
      stub_request(:get, stub_url)
        .with(headers: { 'Accept' => '*/*' })
        .to_return(status: 201, body: responses[:success], headers: {})
    end
    it 'returns a pickup json response' do
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

  context 'When an access patron visits the site' do
    describe '#access_patron' do
      it 'creates an access patron with required access attributes' do
        patron = subject.send(:access_patron, 'foo@bar.com', 'foobar')
        expect(patron).to be_truthy
        expect(patron[:active_email]).to eq('foo@bar.com')
        expect(patron[:last_name]).to eq('foobar')
        expect(patron[:barcode]).to eq('ACCESS')
      end
    end
  end
  context 'A user with a valid princeton net id patron record' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 200, body: valid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = subject.send(:current_patron, user.uid)
        expect(patron).to be_truthy
        expect(patron[:active_email]).to be_truthy
        expect(patron[:netid]).to be_truthy
      end
    end
  end
  context 'A user with a valid barcode patron record' do
    describe '#current_patron' do
      let(:user) { FactoryGirl.create(:valid_barcode_patron) }
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = subject.send(:current_patron, user.uid)
        expect(patron).to be_truthy
        expect(patron[:active_email]).to be_truthy
        expect(patron[:netid].nil?).to be true
      end
    end
  end
  context 'A user with a netid that does not have a matching patron record' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 404, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = subject.send(:current_patron, user.uid)
        expect(patron).to be false
      end
    end
  end
  context 'Cannot connect to Patron Data service' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 403, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = subject.send(:current_patron, user.uid)
        expect(patron).to be false
      end
    end
  end
  context 'System Error from Patron data service' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 500, body: invalid_patron_response, headers: {})
      end
      it 'cannot return a patron record' do
        patron = subject.send(:current_patron, user.uid)
        expect(patron).to be false
      end
    end
  end
end
