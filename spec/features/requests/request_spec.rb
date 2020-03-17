require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes }, type: :feature do
  let(:voyager_id) { '9493318' }
  let(:online_id) { '11169709' }
  let(:thesis_id) { 'dsp01rr1720547' }
  let(:in_process_id) { '10144698' }
  let(:recap_in_process_id) { '10247806' }
  let(:on_order_id) { '10958705' }
  let(:no_items_id) { '3018567' }
  let(:on_shelf_no_items_id) { '308' }
  let(:temp_item_id) { '4815239' }
  let(:temp_id_mfhd) { '5018096' }
  let(:iiif_manifest_item) { '4888494' }

  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

  before(:each) { stub_delivery_locations }

  context 'all patrons' do
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
    describe 'Holding headings', js: true do
      it 'displays the temporary holding location library label' do
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
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button(I18n.t('requests.account.other_user_login_btn'))
        wait_for_ajax
        expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
      end

      it 'allows guest patrons to see aeon requests' do
        visit '/requests/336525'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button(I18n.t('requests.account.other_user_login_btn'))
        wait_for_ajax
        expect(page).to have_content 'Request to View in Reading Room'
      end

      # TODO: Remove when campus has re-opened
      it 'guest patrons can not request a physical recap item during the closure' do
        visit '/requests/9944355'
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_no_content 'Electronic Delivery'
        expect(page).to have_content 'Item is not requestable'
      end

      # TODO: Activate test when campus has re-opened
      xit 'allows guest patrons to request a physical recap item' do
        visit '/requests/9944355'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_no_content 'Electronic Delivery'
        select('Firestone Library', :from => 'requestable__pickup')
        click_button 'Request this Item'
        # wait_for_ajax
        expect(page).to have_content 'Request submitted'
      end

      it 'prohibits guest patrons from requesting In-Process items' do
        visit "/requests/#{in_process_id}"
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'Item is not requestable.'
      end

      it 'prohibits guest patrons from requesting On-Order items' do
        visit "/requests/#{on_order_id}"
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).not_to have_selector('.btn--primary')
      end

      it 'allows guest patrons to access Online items' do
        visit '/requests/9994692'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'www.jstor.org'
      end

      it 'allows guest patrons to request Aeon items' do
        visit '/requests/2167669'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_link('Request to View in Reading Room')
      end

      it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
        visit '/requests/1788796?mfhd=2053005'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_content 'Item is not requestable.'
      end

      it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
        visit '/requests/2286894'
        # click_link(I18n.t('requests.account.other_user_login_msg'))
        fill_in 'request_email', :with => 'name@email.com'
        fill_in 'request_user_name', :with => 'foobar'
        click_button I18n.t('requests.account.other_user_login_btn')
        expect(page).to have_field 'requestable__selected', disabled: false
        expect(page).to have_field 'requestable_selected_7484608', disabled: true
        expect(page).to have_field 'requestable_user_supplied_enum_2576882'
        check('requestable__selected', exact: true)
        fill_in 'requestable_user_supplied_enum_2576882', :with => 'test'
        select('Firestone Library', :from => 'requestable__pickup')
        click_button 'Request Selected Items'
        expect(page).to have_content I18n.t('requests.submit.annexa_success')
      end
    end
  end

  context 'a princeton net ID user' do
    let(:user) { FactoryGirl.create(:user) }

    let(:recap_params) {
      {
        :Bbid => "9493318",
        :barcode => "22101008199999",
        :item => "7303228",
        :lname => "Student",
        :delivery => "p",
        :pickup => "PN",
        :startpage => "",
        :endpage => "",
        :email => "a@b.com",
        :volnum => "",
        :issue => "",
        :aauthor => "",
        :atitle => "",
        :note => ""
      }
    }

    before(:each) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      login_as user
    end

    describe 'When visiting a voyager ID as a CAS User' do
      it 'allow CAS patrons to request an available ReCAP item.' do
        stub_request(:post, Requests.config[:scsb_base]).
          with(headers: { 'Accept' => '*/*' }).
          to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
        visit "/requests/#{voyager_id}"
        expect(page).to have_content 'Electronic Delivery'
        # some weird issue with this and capybara examining the page source shows it is there.
        expect(page).to have_selector '#request_user_barcode', visible: false
        choose('requestable__delivery_mode_7303228_print') # chooses 'print' radio button
        select('Firestone Library', :from => 'requestable__pickup')
        expect(page).to have_button('Request this Item', disabled: false)
      end

      it 'does display the online access message' do
        visit "/requests/#{online_id}"
        expect(page).to have_content 'Online'
      end

      it 'allows CAS patrons to request In-Process items', js: true do
        visit "/requests/#{in_process_id}"
        expect(page).to have_content 'In Process'
        expect(page).to have_button('Request this Item', disabled: false)
        click_button 'Request this Item'
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
      end

      it 'makes sure In-Process items can only be delivered to their holding library', js: true do
        visit "/requests/#{in_process_id}"
        expect(page).to have_content 'In Process'
        expect(page).to have_content 'Pickup location: Marquand Library'
        expect(page).to have_button('Request this Item', disabled: false)
        click_button 'Request this Item'
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
      end

      it 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere', js: true do
        visit "/requests/#{recap_in_process_id}"
        expect(page).to have_content 'In Process'
        select('Firestone Library', :from => 'requestable__pickup')
        select('Lewis Library', :from => 'requestable__pickup')
        click_button 'Request this Item'
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
      end

      it 'allows CAS patrons to request On-Order items' do
        visit "/requests/#{on_order_id}"
        expect(page).to have_button('Request this Item', disabled: false)
      end

      it 'allows CAS patrons to request a record that has no item data' do
        visit "/requests/#{no_items_id}"
        check('requestable__selected', exact: true)
        fill_in 'requestable[][user_supplied_enum]', :with => 'Some Volume'
        expect(page).to have_button('Request Selected Items', disabled: false)
      end

      it 'allows CAS patrons to locate an on_shelf record that has no item data' do
        visit "/requests/#{on_shelf_no_items_id}"
        expect(page).to have_link('Where to find it')
      end

      it 'displays an ark link for a plum item' do
        visit "/requests/#{iiif_manifest_item}"
        expect(page).to have_link('Digital content', href: "https://catalog.princeton.edu/catalog/#{iiif_manifest_item}#view")
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

    describe 'Visits a request page', js: true do
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
      expect(page).to have_selector '#request_user_barcode', visible: false
    end
  end
end
