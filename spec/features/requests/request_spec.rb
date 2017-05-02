require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes }, type: :feature do

  let(:voyager_id) { '9493318' }
  let(:thesis_id) { 'dsp01rr1720547' }
  let(:in_process_id) { '10144698' }
  let(:on_order_id) { '10081566' }
  let(:temp_item_id) { '4815239' }
  let(:temp_id_mfhd) { '5018096' }

  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

  context 'all patrons' do
    describe 'When visiting without a system ID' do
      it "Displays a Not Valid System ID error" do
        visit '/requests'
        expect(page).to have_content "Please Supply a valid Library ID to Request"
      end
    end

    describe 'When unauthenticated patron visits a request item', js: true do
      it "displays three authentication options" do
        visit '/requests/9944355'
        expect(page).to have_content(I18n.t('requests.account.netid_login_msg'))
        expect(page).to have_content(I18n.t('requests.account.barcode_login_msg'))
        expect(page).to have_content(I18n.t('requests.account.other_user_login_msg'))
      end
    end
  end

  context 'Temporary Shelf Locations' do
    describe 'Holding headings' do
      it 'displays the temporary holding location library label', js: true do
        visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button(I18n.t('requests.account.other_user_login_btn'))
        expect(page).to have_content('Engineering Library')
      end

      it 'displays the temporary holding location label' do
        visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button(I18n.t('requests.account.other_user_login_btn'))
        expect(page).to have_content('Reserve')
      end
    end
  end

  context 'unauthenticated patron' do
    describe 'When visiting a request item without logging in', js: true do
      it 'allows guest patrons to identify themselves and view the form' do
        visit '/requests/9944355'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button(I18n.t('requests.account.other_user_login_btn'))
        wait_for_ajax
        expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
      end

      it 'allows guest patrons to request a physical recap item' do
        visit '/requests/9944355'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_no_content 'Electronic Delivery'
        select('Firestone Library', :from => 'requestable__pickup')
        click_button 'Request this Item'
        wait_for_ajax
        expect(page).to have_content 'Request submitted'
      end

      it 'prohibits guest patrons from requesting In-Process items' do
        visit "/requests/#{in_process_id}"
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'In Process'
        expect(page).to have_content 'Item is not requestable.'
      end

      it 'prohibits guest patrons from requesting On-Order items' do
        visit "/requests/#{on_order_id}"
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'Item is not requestable.'
      end

      it 'allows guest patrons to access Online items' do
        visit '/requests/9994692'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'www.jstor.org'
      end

      it 'allows guest patrons to request Aeon items' do
        visit '/requests/2167669'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_link('Request to View in Reading Room')
      end

      it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
        visit '/requests/1788796?mfhd=2053005'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'Item is not requestable.'
      end

      it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
        visit '/requests/2286894'
        click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_field 'requestable__selected', disabled: false
        expect(page).to have_field 'requestable_selected_7484608', disabled: true
        check('requestable__selected', exact: true)
        select('Firestone Library', :from => 'requestable__pickup')
        click_button 'Request Selected Items'
        wait_for_ajax
        expect(page).to have_content 'Request submitted'
      end
    end
  end

  context 'a princeton net ID user' do
    let(:user) { FactoryGirl.create(:user) }

    let(:recap_params) {
      {
        :Bbid=>"9493318",
        :barcode=>"22101008199999",
        :item=>"7303228",
        :lname=>"Student",
        :delivery=>"p",
        :pickup=>"PN",
        :startpage=>"",
        :endpage=>"",
        :email=>"a@b.com",
        :volnum=>"",
        :issue=>"",
        :aauthor=>"",
        :atitle=>"",
        :note=>""
      }
    }

    before(:each) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      login_as user
    end

    describe 'When visiting a voyager ID as a CAS User' do
      it 'allow CAS patrons to request an available ReCAP item.' do
        stub_request(:post, Requests.config[:gfa_base]).
          with(headers: {'Accept'=>'*/*'}).
          to_return(status: 201, body: "<document count='1' sent='true'></document>", headers: {})
        visit "/requests/#{voyager_id}"
        expect(page).to have_content 'Electronic Delivery'
        #some weird issue with this and capybara examining the page source shows it is there.
        #expect(page).to have_selector '#request_user_barcode'
        choose('requestable__delivery_mode_7303228_print') #chooses 'print' radio button
        select('Firestone Library', :from => 'requestable__pickup')
        expect(page).to have_button('Request this Item', disabled: false)
        # click_button 'Request this Item'
        # wait_for_ajax
        # expect(page).to have_content 'Request submitted'
      end

      it 'allows CAS patrons to request In-Process items', js: true do
        visit "/requests/#{in_process_id}"
        expect(page).to have_content 'In Process'
        select('Marquand Library of Art and Archaeology', :from => 'requestable__pickup')
        expect(page).to have_button('Request this Item', disabled: false)
        click_button 'Request this Item'
        wait_for_ajax
        expect(page).to have_content 'Request submitted'
        # expect(page).to have_content 'We were unable to process your request'
      end

      it 'allows CAS patrons to request On-Order items' do
        visit "/requests/#{on_order_id}"
        expect(page).to have_button('Request this Item', disabled: false)
      end
    end
  end

  context 'A Princeton net ID user without a bibdata record' do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
        .to_return(status: 404, body: invalid_patron_response, headers: {})
      login_as user
    end

    describe 'Visits a request page' do
      it 'Tells the user their patron record is not available' do
        visit "/requests/#{on_order_id}"
        expect(page).to have_content(I18n.t("requests.account.auth_user_lookup_fail"))
      end
    end
  end

  context 'A barcode holding user' do
    let(:user) { FactoryGirl.create(:valid_barcode_patron) }

    it 'display a request form for a ReCAP item.' do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
      login_as user
      visit "/requests/#{voyager_id}"
      expect(page).to have_content 'Electronic Delivery'
      #expect(page).to have_selector '#request_user_barcode'
    end
  end
end
