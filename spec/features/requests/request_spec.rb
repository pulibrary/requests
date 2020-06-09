require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes }, type: :feature do
  # rubocop:disable RSpec/MultipleExpectations
  describe "request form" do
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
    let(:mutiple_items) { '7917192' }

    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
    let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

    before { stub_delivery_locations }

    context 'all patrons' do
      describe 'When unauthenticated patron visits a request item', js: true do
        it "displays three authentication options" do
          visit '/requests/9944355'
          expect(page).to have_content(I18n.t('requests.account.netid_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.barcode_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.other_user_login_msg'))
        end
      end
    end

    context 'Temporary Shelf Locations' do
      describe 'Holding headings', js: true do
        it 'displays the temporary holding location library label' do
          visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          expect(page).to have_content('Engineering Library')
        end

        it 'displays the temporary holding location label' do
          visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          expect(page).to have_content('Reserve')
        end
      end
    end

    context 'unauthenticated patron' do
      describe 'When visiting a request item without logging in', js: true do
        it 'allows guest patrons to identify themselves and view the form' do
          visit '/requests/9944355'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
        end

        it 'allows guest patrons to see aeon requests' do
          visit '/requests/336525'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'Request to View in Reading Room'
        end

        # TODO: Remove when campus has re-opened
        it 'guest patrons can not request a physical recap item during the closure' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9944355'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_no_content 'Electronic Delivery'
          expect(page).to have_content 'Item is not requestable'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guest patrons to request a physical recap item' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9944355'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_no_content 'Electronic Delivery'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request this Item'
          # wait_for_ajax
          expect(page).to have_content 'Request submitted'
        end

        it 'prohibits guest patrons from requesting In-Process items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{in_process_id}"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'Item is not requestable.'
        end

        it 'prohibits guest patrons from requesting On-Order items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{on_order_id}"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).not_to have_selector('.btn--primary')
        end

        it 'allows guest patrons to access Online items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9994692'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'www.jstor.org'
        end

        it 'allows guest patrons to request Aeon items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/2167669'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_link('Request to View in Reading Room')
        end

        it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/1788796?mfhd=2053005'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'Item is not requestable.'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/2286894'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_selected_7484608', disabled: true
          expect(page).to have_field 'requestable_user_supplied_enum_2576882'
          check('requestable__selected', exact: true)
          fill_in 'requestable_user_supplied_enum_2576882', with: 'test'
          select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request Selected Items'
          expect(page).to have_content I18n.t('requests.submit.annexa_success')
        end
      end
    end

    context 'a princeton net ID user' do
      let(:user) { FactoryGirl.create(:user) }

      let(:recap_params) do
        {
          Bbid: "9493318",
          barcode: "22101008199999",
          item: "7303228",
          lname: "Student",
          delivery: "p",
          pickup: "PN",
          startpage: "",
          endpage: "",
          email: "a@b.com",
          volnum: "",
          issue: "",
          aauthor: "",
          atitle: "",
          note: ""
        }
      end

      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 200, body: valid_patron_response, headers: {})
        login_as user
      end

      describe 'When visiting a voyager ID as a CAS User' do
        it 'allow CAS patrons to request an available ReCAP item.' do
          stub_request(:post, Requests.config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          # some weird issue with this and capybara examining the page source shows it is there.
          expect(page).to have_selector '#request_user_barcode', visible: false
          choose('requestable__delivery_mode_7303228_print') # chooses 'print' radio button
          # temporary changes issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          expect(page).to have_button('Request this Item', disabled: false)
        end

        it 'does display the online access message' do
          visit "/requests/#{online_id}"
          expect(page).to have_content 'Online'
        end

        it 'allows CAS patrons to request In-Process items and can only be delivered to their holding library', js: true do
          visit "/requests/#{in_process_id}"
          expect(page).to have_content 'In Process'
          expect(page).to have_content 'Pick-up location: Marquand Library'
          expect(page).to have_button('Request this Item', disabled: false)
          click_button 'Request this Item'
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
        end

        it 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere', js: true do
          visit "/requests/#{recap_in_process_id}"
          expect(page).to have_content 'In Process'
          # temporary changes issue 438
          select('Firestone Library', from: 'requestable__pickup')
          # select('Lewis Library', from: 'requestable__pickup')
          click_button 'Request this Item'
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
        end

        it 'allows CAS patrons to request On-Order items' do
          visit "/requests/#{on_order_id}"
          pending "must circulate to be requestable"
          expect(page).to have_button('Request this Item', disabled: false)
        end

        it 'allows CAS patrons to request a record that has no item data' do
          visit "/requests/#{no_items_id}"
          check('requestable__selected', exact: true)
          fill_in 'requestable[][user_supplied_enum]', with: 'Some Volume'
          expect(page).to have_button('Request Selected Items', disabled: false)
        end

        it 'allows CAS patrons to locate an on_shelf record that has no item data' do
          visit "/requests/#{on_shelf_no_items_id}"
          select('Firestone Library', from: 'requestable__pickup')
          expect(page).to have_content "ReCAP Paging Request"
          expect(page).to have_content "Paging Request, will be delivered to:\nFirestone Library"
          # temporary changes 438
          # expect(page).to have_content 'Help Me Get It' # while recap is closed
          # expect(page).to have_link('Where to find it')
        end

        it 'allows CAS patrons to locate an on_shelf record' do
          stub_voyager_hold_success('9770811', '7502706', '77777')

          visit "/requests/9770811"
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Pageable item at Firestone Library. Request for pick-up.'
          expect(page).to have_content I18n.t("requests.on_shelf_edd.request_label")
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (F) PG3455 .A2 2015")
          expect(email.to).to eq(["fstpage@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("Chekhov, Anton Pavlovich")
          expect(confirm_email.subject).to eq("Firestone Library Pick-up Request")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Chekhov, Anton Pavlovich")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
        end

        it 'displays an ark link for a plum item' do
          visit "/requests/#{iiif_manifest_item}"
          expect(page).to have_link('Digital content', href: "https://catalog.princeton.edu/catalog/#{iiif_manifest_item}#view")
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        it 'allows patrons to request a physical recap item' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9944355'
          expect(page).to have_content 'Electronic Delivery'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          choose('requestable__delivery_mode_7467161_edd') # chooses 'edd' radio button
          fill_in "Article/Chapter Title", with: "ABC"
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to request a Forrestal annex' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/945550'
          expect(page).to have_content 'Item offsite at Forrestal Annex. Request for pick-up'
          expect(page).to have_content 'Digitization Request'
          # temporary change issue 438
          select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request Selected Items'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to request a Lewis' do
          pending "Lewis library closed"
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/426420'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check 'requestable_selected_7993830'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request Selected Items'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to request a on-order' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11416426'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to ask for help on non circulating items' do
          visit '/requests/9594840'
          expect(page).to have_content 'Help Me Get It'
          expect(page).not_to have_css '.submit--request'
        end

        it 'allows patrons to request a PPL Item' do
          pending "PPL library closed"
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/578830'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows filtering items by mfhd' do
          pending "Lewis library closed"
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192?mfhd=7699134'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'show all copies if MFHD is not present' do
          pending "Lewis library closed"
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Copy 2'
          expect(page).to have_content 'Copy 3'
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.)' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit 'requests/10574699'
          expect(page).not_to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_10320354", with: "ABC ZZZ"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Paging Request for Firestone Library")
          expect(email.to).to eq(["fstpage@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.subject).to eq("Paging Request for Firestone Library")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask")
        end

        # TODO: once Marquad in library use is available again it should show pickup at marquand also
        it 'Shows marqaund as an EDD option only' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11780965?mfhd=11443781'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Electronic Delivery '
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Article/Chapter Title *'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(email.html_part.body.to_s).to have_content("You will receive an email including a link where you can download your scanned section")
        end
      end
    end

    context 'A Princeton net ID user without a bibdata record' do
      let(:user) { FactoryGirl.create(:user) }
      before do
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
      # change this back #438
      it 'display a request form for a ReCAP item.' do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}")
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
        login_as user
        visit "/requests/#{voyager_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_selector '#request_user_barcode', visible: false
      end
    end
  end

  # rubocop:enable RSpec/MultipleExpectations
end
