require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes }, type: :feature do

  let(:voyager_id) { '9493318' }
  let(:thesis_id) { 'dsp01rr1720547' }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_guest.json') }
  
  describe 'When visiting without a system ID' do
    it "Displays a Not Valid System ID error" do
      visit '/requests'
      expect(page).to have_content "Please Supply a valid Library ID to Request"
    end
  end

  # # when current_user is available test these
  # describe 'When visitng with a system id' do
  #   it 'from Voyager' do
  #     visit '/requests/9493318'
  #     expect(page).to have_content voyager_id
  #   end

  #   it 'from a Theses' do
  #     visit "/requests/#{thesis_id}"
  #     expect(page).to have_content thesis_id
  #   end
  # end

  context 'a princeton net ID user' do
    let(:user) { FactoryGirl.create(:user) }
    describe 'When visiting a voyager ID as a CAS User' do
      it 'displays the sign in page with a CAS User message' do
        visit "/requests/#{voyager_id}"
        expect(page).to have_content I18n.t('requests.account.other_user_login_msg')
      end

      it 'display a request form for a ReCAP item.' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
          .to_return(status: 200, body: valid_patron_response, headers: {})
        login_as user
        visit "/requests/#{voyager_id}"
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_selector '#request_user_barcode'
      end
    end
  end

  context 'A barcode holding user' do
    let(:user) { FactoryGirl.create(:valid_barcode_patron) }

    it 'displays the sign in page with a CAS User message' do
        visit "/requests/#{voyager_id}"
        expect(page).to have_content I18n.t('requests.account.other_user_login_msg')
      end

      it 'display a request form for a ReCAP item.' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
        login_as user
        visit "/requests/#{voyager_id}"
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_selector '#request_user_barcode'
      end
  end
end
