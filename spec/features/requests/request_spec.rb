require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes }, type: :feature do
  # rubocop:disable RSpec/MultipleExpectations
  describe "request form" do
    let(:voyager_id) { '9994933183506421?mfhd=22131438430006421' }
    let(:thesis_id) { 'dsp01rr1720547' }
    let(:in_process_id) { '99121095223506421?mfhd=22183262530006421' }
    # going to need to review this with Mark to see if this example is good
    let(:recap_in_process_id) { '99105873133506421?mfhd=22251746380006421' }
    let(:on_order_id) { '99120493093506421?mfhd=2251949020006421' }
    let(:no_items_id) { '9941274093506421?mfhd=22197827810006421' }
    let(:on_shelf_no_items_id) { '993083506421?mfhd=22261908670006421' }
    let(:temp_item_id) { '4815239' }
    let(:temp_id_mfhd) { '5018096' }
    let(:mutiple_items) { '9979171923506421' }

    let(:patron_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/jstudent" }
    let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
    let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:valid_patron_no_barcode_response) { fixture('/bibdata_patron_no_barcode_response.json') }
    let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
    let(:valid_barcode_patron_pick_up_only_response) { fixture('/bibdata_patron_barcode_pick_up_only_response.json') }
    let(:valid_patron_no_campus_response) { fixture('/bibdata_patron_response_no_campus.json') }
    let(:valid_graduate_student_no_campus_response) { fixture('/bibdata_patron_response_graduate_no_campus.json') }
    let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

    let(:responses) do
      {
        found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
        disavowed: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"DIS","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
        transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                            '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                            '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
        note_created: '{"Message":"An error occurred adding note to transaction 1093946"}'
      }
    end

    before do
      stub_delivery_locations
    end

    context 'all patrons' do
      describe 'When unauthenticated patron visits a request item', js: true do
        it "displays three authentication options" do
          visit '/requests/9999443553506421?mfhd=22202822560006421'
          expect(page).to have_content(I18n.t('requests.account.netid_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.barcode_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.other_user_login_msg'))
        end
      end
    end

    context 'Temporary Shelf Locations' do
      describe 'Holding headings', js: true do
        it 'displays the temporary holding location library label' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          expect(page).to have_content('Engineering Library')
        end

        it 'displays the temporary holding location label' do
          pending "Guest have no access during COVID-19 pandemic"
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
          visit '/requests/9999443553506421?mfhd=22202822560006421'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
        end

        it 'allows guest patrons to see aeon requests' do
          visit '/requests/993365253506421?mfhd=22220245570006421'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'Request to View in Reading Room'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guest patrons to request a physical recap item' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9999443553506421?mfhd=22202822560006421'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_no_content 'Electronic Delivery'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
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
          visit '/requests/9994692?mfhd=9800910'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'www.jstor.org'
        end

        it 'allows guest patrons to request Aeon items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9921676693506421'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_link('Request to View in Reading Room')
        end

        it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9917887963506421?mfhd=22196156490006421'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'Item is not requestable.'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9922868943506421'
          click_link(I18n.t('requests.account.other_user_login_msg'))
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_selected_7484608', disabled: true
          expect(page).to have_field 'requestable_user_supplied_enum_2576882'
          check('requestable__selected', exact: true)
          fill_in 'requestable_user_supplied_enum_2576882', with: 'test'
          select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request Selected Items'
          expect(page).to have_content I18n.t('requests.submit.annex_success')
        end
      end
    end

    context 'a princeton net ID user' do
      let(:user) { FactoryGirl.create(:user) }

      let(:recap_params) do
        {
          Bbid: "9994933183506421",
          barcode: "23131438400006421",
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
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_response, headers: {})
        login_as user
      end

      describe 'When visiting a voyager ID as a CAS User' do
        xit 'allow CAS patrons to request an available ReCAP item.' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "9994933183506421", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                       requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, Requests.config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          # some weird issue with this and capybara examining the page source shows it is there.
          expect(page).to have_selector '#request_user_barcode', visible: false
          choose('requestable__delivery_mode_23131438400006421_print') # chooses 'print' radio button
          select('Firestone Library', from: 'requestable__pick_up')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content I18n.t("requests.submit.recap_success")
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("ʻAwāṭif madfūnah")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        # it 'allow CAS patrons to request an available ReCAP item with Help Me' do
        #   visit "/requests/#{voyager_id}"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        xit 'allows CAS patrons to request In-Process items and can only be delivered to their holding library' do
          visit "/requests/#{in_process_id}"
          expect(page).to have_content 'In Process'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_button('Request this Item', disabled: false)
          click_button 'Request this Item'
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
        end

        xit 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere' do
          visit "/requests/#{recap_in_process_id}"
          expect(page).to have_content 'In Process'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("In Process Request")
          expect(email.to).to eq(["fstcirc@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("Unrecognised by the world at large")
          expect(confirm_email.subject).to eq("In Process Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Unrecognised by the world at large")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        # it 'makes sure In-Process ReCAP items get Help Me' do
        #   visit "/requests/#{recap_in_process_id}"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        it 'allows CAS patrons to request On-Order items' do
          visit "/requests/#{on_order_id}"
          expect(page).to have_button('Request this Item', disabled: false)
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t("requests.submit.on_order_success")
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On Order Request")
          expect(email.to).to eq(["fstcirc@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("The declaration of war on Cleopatra : an examination of the evidence for the antiquity of the ceremony enacted by Octavian in the Campus Martius")
          expect(confirm_email.subject).to eq("On Order Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("The declaration of war on Cleopatra : an examination of the evidence for the antiquity of the ceremony enacted by Octavian in the Campus Martius")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        it 'allows CAS patrons to request a record that has no item data' do
          visit "/requests/99113283293506421?mfhd=2256094420006421"
          check('requestable__selected', exact: true)
          fill_in 'requestable[][user_supplied_enum]', with: 'Some Volume'
          expect(page).to have_button('Request this Item', disabled: false)
        end

        xit 'allows CAS patrons to locate an on_shelf record that has no item data' do
          visit "/requests/#{on_shelf_no_items_id}"
          choose('requestable__delivery_mode_22261908670006421_print') # chooses 'print' radio button
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up')
          expect(page).to have_content "ReCAP Paging Request"
        end

        it 'allows CAS patrons to locate an on_shelf record' do
          stub_alma_hold_success('9912636153506421', '22272105130006421', '23272105120006421', '960594184')

          visit "requests/9912636153506421?mfhd=22272105130006421"
          expect(page).to have_content 'Pick-up location: Firestone Library'
          choose('requestable__delivery_mode_23272105120006421_print') # chooses 'print' radio button
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (FIRESTONE$STACKS) PR3187 .L443 1951")
          expect(email.to).to eq(["fstpage@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("John Webster; a critical study")
          expect(email.html_part.body.to_s).not_to have_content("9912636153506421") # does not show detailed metadata
          expect(confirm_email.subject).to eq("Firestone Library Pick-up Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("John Webster; a critical study")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        xit 'allows patrons to request a physical recap item' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "9999443553506421", callNumber: "DT549 .E274q Oversize", chapterTitle: "ABC", deliveryLocation: "PA", emailAddress: "a@b.com", endPage: "", issue: "",
                                       itemBarcodes: ["32101098722844"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "L'écrivain, magazine litteraire trimestriel", username: "jstudent", volume: "2016"))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
            .with(body: hash_including(bibliographicId: "9999443553506421", institutionId: "PUL"))
            .to_return(status: 200, body: "[{\"itemBarcode\":\"32101098722844\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"}]", headers: {})
          visit '/requests/9999443553506421?mfhd=22202822560006421'
          expect(page).to have_content 'Electronic Delivery'
          select('Firestone Library', from: 'requestable__pick_up')
          choose('requestable__delivery_mode_23202822550006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("L'écrivain, magazine litteraire trimestriel")
        end

        # it 'allows patrons to request a physical recap item get Help Me' do
        #   visit "/requests/9944355?mfhd=9757511"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        it 'allows patrons to request a Forrestal annex' do
          visit '/requests/999455503506421?mfhd=2221072930006421'
          choose('requestable__delivery_mode_2321072920006421_print') # chooses 'print' radio button
          # todo: should we still have the text?
          # expect(page).to have_content 'Item offsite at Forrestal Annex. Requests for pick-up'
          expect(page).to have_content 'Electronic Delivery'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up')
          select('Firestone Library', from: 'requestable__pick_up')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content 'Request submitted'
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Annex Request")
          expect(email.to).to eq(["forranx@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
          expect(confirm_email.subject).to eq("Annex Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        xit 'allows patrons to request a Lewis recap item digitally' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9970533073506421?mfhd=22214952010006421'
          choose('requestable__delivery_mode_23214952000006421_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Pick-up location: Lewis Library'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        end

        it 'allows patrons to request a Lewis' do
          stub_alma_hold_success('9970533073506421', '22214952030006421', '23214952020006421', '960594184')
          visit '/requests/9970533073506421?mfhd=22214952030006421'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          check 'requestable_selected_23214952020006421'
          # temporary change issue 438
          # choose('requestable__delivery_mode_23214952020006421_print') # chooses 'edd' radio button
          # select('Firestone Library', from: 'requestable__pick_up')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content 'Item has been requested for pick-up'
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (LEWIS$STACKS) QA646 .A44 2012")
          expect(email.to).to eq(["lewislib@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
          expect(confirm_email.subject).to eq("Lewis Library Pick-up Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        end

        it 'allows patrons to request a on-order' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          ## having trouble finding a firestone item in BL.
          visit '/requests/99121699843506421?mfhd=22184441650006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request this Item'
          expect(a_request(:post, scsb_url)).not_to have_been_made
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to ask for digitizing on non circulating items' do
          visit '/requests/9995948403506421?mfhd=2258775160006421'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_css '.submit--request'
        end

        it 'allows patrons to request a PPL Item' do
          pending "PPL library closed"
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/995788303506421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows filtering items by mfhd' do
          visit '/requests/9979171923506421?mfhd=22230315750006421'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a print copy' do
          visit 'requests/99105746993506421?mfhd=22217601660006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_22217601660006421", with: "ABC ZZZ"
          choose('requestable__delivery_mode_22217601660006421_print') # choose the print radio button
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Paging Request for Firestone Library")
          expect(email.to).to eq(["fstpage@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.subject).to eq("Paging Request for Firestone Library")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a electronic copy' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => "", "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/99105746993506421", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ",
                                       "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit 'requests/99105746993506421?mfhd=22217601660006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_22217601660006421", with: "ABC ZZZ"
          choose('requestable__delivery_mode_22217601660006421_edd') # choose the print radio button
          within("#fields-eed__22217601660006421") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
          end
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        xit 'Shows Marqaund Recap Item as an EDD option or In Library Use, no delivery' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/99117809653506421?mfhd=22203397510006421'
          choose('requestable__delivery_mode_23203397500006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.recap_edd.brief_msg')
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Article/Chapter Title (Required)'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(email.html_part.body.to_s).to have_content("You will receive an email including a link where you can download your scanned section")
        end

        it "shows items in the Architecture Library as available" do
          stub_alma_hold_success('99117876713506421', '22196862260006421', '23196862250006421', '960594184')
          visit '/requests/99117876713506421?mfhd=22196862260006421'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Pick-up location: Architecture Library'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (ARCH$STACKS) NA1585.A23 S7 2020")
          expect(email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
          expect(confirm_email.subject).to eq("Architecture Library Pick-up Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
        end

        xit "allows requests of recap pick-up only items" do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: nil, bibId: "99115783193506421", callNumber: "DVD", chapterTitle: nil, deliveryLocation: "PA", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["32101108035435"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "Chernobyl : a 5-part miniseries", username: "jstudent", volume: nil))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/99115783193506421?mfhd=22155047580006421'
          expect(page).not_to have_content 'Item is not requestable.'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).to have_content 'Item off-site at ReCAP facility. Request for delivery in 1-2 business days.'
          select('Firestone Library', from: 'requestable__pick_up')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Chernobyl : a 5-part miniseries")
        end

        it 'doe snot error for Online items' do
          visit '/requests/9999946923506421?mfhd=9800910'
          expect(page).to have_content 'there are no requestable items for this record'
        end

        it 'Borrow Direct successful on Missing items' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_return('123456')
          visit '/requests/9917887963506421?mfhd=22196156490006421'
          expect(page).to have_content 'Request via Partner Library'
          check('requestable_selected_23196156480006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(page).to have_content 'Request submitted to BorrowDirect'
          expect(page).to have_content 'Your request number is 123456'
          expect(page).not_to have_content 'Your request was submittied. Our library staff will review the request and contact you with aviable options.'
        end

        it 'Borrow direct unsuccessful, but no exception thrown sent on to illiad' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_return(nil)
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9917887963506421?mfhd=22196156490006421'
          expect(page).to have_content 'Request via Partner Library'
          check('requestable_selected_23196156480006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
        end

        it 'Borrow Direct unsuccessful on missing item sent to illiad' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_raise(::BorrowDirect::Error, "Error with borrow direct")
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9917887963506421?mfhd=22196156490006421'
          expect(page).to have_content 'Request via Partner Library'
          check('requestable_selected_23196156480006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
        end

        it 'allow interlibrary loan to be requested' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "U.S. census office", "LoanTitle" => "7th census of U.S.1850",
                                       "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "HA202.1850.A5q Oversize", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9915057783506421", "ItemInfo3" => "", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9915057783506421?mfhd=2259945160006421'
          expect(page).to have_content 'Request via Partner Library'
          check('requestable_selected_2359945150006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("7th census of U.S.1850")
        end

        it 'allows cas user to request from Annex or Firestone in mixed holding' do
          visit '/requests/9922868943506421?mfhd=22109192600006421'
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_22109192600006421'
          within('#request_user_supplied_22109192600006421') do
            check('requestable__selected', exact: true)
            fill_in 'requestable_user_supplied_enum_22109192600006421', with: 'test'
          end
          select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request Selected Items'
          expect(page).to have_content I18n.t('requests.submit.annex_success')
        end

        it 'allows a non circulating item with no item data to be digitized' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                       "Location" => "Marquand Library - Marquand Library", "ISSN" => "9783905597363", "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9941274093506421", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand EDD", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_clancy_status(barcode: "32101072349515")
          visit '/requests/9941274093506421?mfhd=22197827810006421'
          choose('requestable__delivery_mode_22197827810006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.marquand_edd.brief_msg')
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Not Available'
          expect(page).not_to have_content 'Available for In Library Use'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          expect(marquand_email.html_part.body.to_s).to have_content("ABC")
          expect(marquand_email.html_part.body.to_s).to have_content("I Aman Author")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it 'allows an in process item to be requested from marquand' do
          # TODO: there is not really a good example of an in process item currently
          stub_clancy_status(barcode: "32101097503864")
          visit 'requests/99101378413506421?mfhd=22201004360006421'
          expect(page).to have_content 'In Process materials are typically available in several business days'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("In Process Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("In Process materials can typically be picked up at the Circulation Desk of your choice in several business days")
          expect(confirm_email.html_part.body.to_s).to have_content("ASIA COLLECTION 100: FROM THE COLLECTION OF THE FUKUOKA ASIAN ART MUSEUM")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("In Process Request")
          expect(marquand_email.html_part.body.to_s).to have_content("ASIA COLLECTION 100: FROM THE COLLECTION OF THE FUKUOKA ASIAN ART MUSEUM")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

          it 'allows a non circulating item with no item data to be digitized' do
            stub_request(:get, patron_url)
              .to_return(status: 200, body: responses[:found], headers: {})
            stub_request(:post, transaction_url)
              .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                         "Location" => "Marquand Library", "ISSN" => "9783905597363", "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/4127409", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand EDD", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
              .to_return(status: 200, body: responses[:transaction_created], headers: {})
            stub_request(:post, transaction_note_url)
              .to_return(status: 200, body: responses[:note_created], headers: {})
            stub_clancy_status(barcode: "32101072349515")
            visit '/requests/9941274093506421?mfhd=22197827810006421'
            expect(page).to have_content 'Electronic Delivery'
            choose('requestable__delivery_mode_22197827810006421_edd') # chooses 'edd' radio button
            fill_in "Article/Chapter Title", with: "ABC"
            fill_in "Author", with: "I Aman Author"
            expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
            expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
            marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
            expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
            expect(marquand_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
            expect(marquand_email.html_part.body.to_s).to have_content("ABC")
            expect(marquand_email.html_part.body.to_s).to have_content("I Aman Author")
            expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
            expect(marquand_email.cc).to be_blank
          end

        # it 'allows an etas item to be digitized' do
        #   # TODO: - Do we need to worry about ETAS? No, PUL ETAS is being deprecated at alma go live
        #   stub_request(:get, patron_url)
        #     .to_return(status: 200, body: responses[:found], headers: {})
        #   stub_request(:post, transaction_url)
        #     .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Edwards, Ruth Dudley", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "James Connolly", "PhotoItemPublisher" => "Dublin: Gill and Macmillan", "ISSN" => "9780717111121 9780717111114", "CallNumber" => "DA965.C7 E36 1981", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/991626323506421", "PhotoJournalYear" => "1981", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "8391816", "DocumentType" => "Book", "Location" => "Online - HathiTrust Emergency Temporary Access", "PhotoArticleTitle" => "ABC"))
        #     .to_return(status: 200, body: responses[:transaction_created], headers: {})
        #   stub_request(:post, transaction_note_url)
        #     .to_return(status: 200, body: responses[:note_created], headers: {})
        #   visit '/requests/991626323506421?mfhd=2239424020006421'
        #   expect(page).to have_content 'Electronic Delivery'
        #   expect(page).to have_content 'Online- HathiTrust Emergency Temporary Access DA965.C7 E36 1981'
        #   expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
        #   expect(page).not_to have_content('make an appointment')
        #   fill_in "Article/Chapter Title", with: "ABC"
        #   expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
        #   expect(page).to have_content 'Request submitted'
        #   confirm_email = ActionMailer::Base.deliveries.last
        #   expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.to).to eq(["a@b.com"])
        #   expect(confirm_email.cc).to be_blank
        #   expect(confirm_email.html_part.body.to_s).to have_content("James Connolly")
        # end

        # it "allows an Recap etas item to be digitized" do
        #   # TODO: - Do we need to worry about ETAS?
        #   scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        #   stub_request(:post, scsb_url)
        #     .with(body: hash_including(author: "", bibId: "7599", callNumber: "PJ3002 .S4", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101073604215"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Semitistik", username: "jstudent", volume: ""))
        #     .to_return(status: 200, body: good_response, headers: {})
        #   visit '/requests/9975993506421?mfhd=22153200840006421'
        #   expect(page).to have_content 'Electronic Delivery'
        #   expect(page).to have_content 'ReCAP- HathiTrust Emergency Temporary Access ReCAP PJ3002 .S4'
        #   expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
        #   expect(page).not_to have_content 'If the specific volume does not appear in the list below, please enter it here:'
        #   fill_in "Article/Chapter Title", with: "ABC"
        #   expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
        #   expect(a_request(:post, scsb_url)).to have_been_made
        #   confirm_email = ActionMailer::Base.deliveries.last
        #   expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
        #   expect(confirm_email.html_part.body.to_s).to have_content("Semitistik")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask or face covering")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("Please do not use disinfectant or cleaning product on books")
        # end

        # need to check on CUL etas
        xit "allows a columbia item that is not in hathi etas to be picked up or digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=21154437")
            .to_return(status: 200, body: '[]')
          stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/SCSB-2879197/raw")
            .to_return(status: 200, body: fixture('/SCSB-2879197.json'), headers: {})
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-2879197", callNumber: "PG3479.3.I84 Z778 1987g", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU01805363"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879197'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497908_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP PG3479.3.I84 Z778 1987g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        xit "allows a columbia item that is open access to be picked up or digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=502557695")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"502557695","bibid":"9938633913506421","status":"ALLOW","origin":"CUL"}]')
          stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/SCSB-4634001/raw")
            .to_return(status: 200, body: fixture('/SCSB-4634001.json'), headers: {})
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-4634001", callNumber: "4596 2907.88 1901", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU51481294"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Chong wen men shang shui ya men xian xing shui ze. 崇文門 商稅 衙門 現行 稅則.", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-4634001'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_6826565_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP 4596 2907.88 1901'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(" Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Chong wen men shang shui ya men xian xing shui ze")
          expect(confirm_email.html_part.body.to_s).to have_content("Remain only in the designated pick-up area")
        end

        xit "allows a columbia item that is ETAS to only be digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=19774500")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"19774500","bibid":"99310000663506421","status":"DENY","origin":"CUL"}]')
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/SCSB-2879206/raw")
            .to_return(status: 200, body: fixture('/SCSB-2879206.json'), headers: {})
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-2879206", callNumber: "ML3477 .G74 1989g", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU61436348"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Let's face the music : the golden age of popular song", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879206'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497920_edd') # chooses 'edd' radio button
          fill_in "Article/Chapter Title", with: "ABC"
          expect(page).to have_content 'ReCAP ML3477 .G74 1989g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
          expect(confirm_email.html_part.body.to_s).to have_content("Let's face the music : the golden age of popular song")
          expect(confirm_email.html_part.body.to_s).to have_content("ABC")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "places a hold and sends emails for a marquand in library use item" do
          stub_alma_hold_success('9956364873506421', '22186505500006421', '23186505470006421', '960594184')
          stub_clancy_status(barcode: "32101072349515")
          visit '/requests/9956364873506421?mfhd=22186505500006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_link('make an appointment', href: "https://libcal.princeton.edu/seats?lid=10656")
          choose('requestable__delivery_mode_23186505470006421_in_library') # chooses 'in library' radio button
          expect(page).to have_content('Marquand Library at Firestone')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("You will be notified via email when your item is available.")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Pick-up By")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request In Library")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "places a hold and a clancy request for a marquand in library use item at Clancy" do
          stub_alma_hold_success('9956364873506421', '22186505500006421', '23186505470006421', '960594184')
          stub_clancy_status(barcode: "32101072349515", status: "Item In at Rest")
          stub_clancy_post(barcode: "32101072349515")
          visit '/requests/9956364873506421?mfhd=22186505500006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          choose('requestable__delivery_mode_23186505470006421_in_library') # chooses 'in_library' radio button
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy In Library")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "only has edd for a marquand in library use item at Clancy that is unavailable" do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Cambridge, Mass: Harvard University P...", "ISSN" => "9780674030930", "CallNumber" => "N7668.D6 J64 2008", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9956364873506421",
                                       "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy UNAVAIL EDD", "AcceptNonEnglish" => true, "ESPNumber" => "213495319", "DocumentType" => "Book", "Location" => "Marquand Library - Marquand Library", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Digitization Request Marquand Item at Clancy (Unavailable)"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_clancy_status(barcode: "32101072349515", status: "Item In Accession Process")
          visit '/requests/9956364873506421?mfhd=22186505500006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).not_to have_content 'Available for In Library Use'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_23186505470006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.clancy_unavailable_edd.brief_msg')
          expect(page).to have_content I18n.t("requests.clancy_unavailable_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect(page).not_to have_content("translation missing")
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t("requests.clancy_unavailable_edd.email_conf_msg"))
          expect(confirm_email.html_part.body.to_s).to have_content("ABC")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan - Unavailable at Clancy")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.html_part.body.to_s).to have_content("ABC")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "sends an email and places an illiad request for a marquand edd item at Clancy" do
          stub_alma_hold_success('9956364873506421', '22186505500006421', '23186505470006421', '960594184')
          stub_clancy_status(barcode: "32101072349515", status: "Item In at Rest")
          stub_clancy_post(barcode: "32101072349515")
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Cambridge, Mass: Harvard University P...", "ISSN" => "9780674030930", "CallNumber" => "N7668.D6 J64 2008", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9956364873506421",
                                       "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy EDD", "AcceptNonEnglish" => true, "ESPNumber" => "213495319", "DocumentType" => "Book", "Location" => "Marquand Library - Marquand Library", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Digitization Request Marquand Item at Clancy"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9956364873506421?mfhd=22186505500006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          choose('requestable__delivery_mode_23186505470006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.clancy_edd.brief_msg')
          expect(page).to have_content I18n.t("requests.clancy_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 4-8 business days")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        xit "shows in library use option for SCSB ReCAP items in Firestone" do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: nil, bibId: "SCSB-8953469", callNumber: "ReCAP 18-69309", chapterTitle: nil, deliveryLocation: "QX", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["33433121206696"], itemOwningInstitution: "NYPL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "1955-1968 : gli artisti italiani alle Documenta di Kassel", username: "jstudent", volume: nil))
            .to_return(status: 200, body: good_response, headers: {})
          stub_scsb_availability(bib_id: ".b215204128", institution_id: "NYPL", barcode: '33433121206696')
          stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/SCSB-8953469/raw")
            .to_return(status: 200, body: fixture('/SCSB-8953469.json'), headers: {})
          visit 'requests/SCSB-8953469'
          expect(page).not_to have_content 'Help Me Get It'
          expect(page).to have_content 'Available for In Library'
          expect(page).not_to have_content 'Electronic Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("955-1968 : gli artisti italiani alle Documenta di Kassel")
        end

        xit 'Shows marqaund recap item as an EDD or In Library Use' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "99117809653506421", callNumber: "N6923.B257 H84 2020", chapterTitle: "", deliveryLocation: "PJ", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101106347378"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Alesso Baldovinetti und die Florentiner Malerei der Frührenaissance", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/99117809653506421?mfhd=22203397510006421'
          choose('requestable__delivery_mode_23203397500006421_in_library') # chooses 'in_library' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library'
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          expect(page).not_to have_content 'Physical Item Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(a_request(:post, scsb_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("2-4 business days")
          expect(confirm_email.html_part.body.to_s).to have_content("Alesso Baldovinetti und die Florentiner Malerei der Frührenaissance")
        end
      end
    end

          xit "shows in library use option for SCSB ReCAP items in Firestone" do
            scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
            stub_request(:post, scsb_url)
              .with(body: hash_including(author: nil, bibId: "SCSB-8953469", callNumber: "ReCAP 18-69309", chapterTitle: nil, deliveryLocation: "QX", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["33433121206696"], itemOwningInstitution: "NYPL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "1955-1968 : gli artisti italiani alle Documenta di Kassel", username: "jstudent", volume: nil))
              .to_return(status: 200, body: good_response, headers: {})
            stub_scsb_availability(bib_id: ".b215204128", institution_id: "NYPL", barcode: '33433121206696')
            visit 'requests/SCSB-8953469'
            expect(page).not_to have_content 'Help Me Get It'
            expect(page).to have_content 'Available for In Library'
            expect(page).not_to have_content 'Electronic Delivery'
            expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
            expect(a_request(:post, scsb_url)).to have_been_made
            expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.html_part.body.to_s).to have_content("955-1968 : gli artisti italiani alle Documenta di Kassel")
          end

      describe 'Visits a request page', js: true do
        it 'Tells the user their patron record is not available' do
          visit "/requests/99117809653506421?mfhd=22203397510006421"
          expect(a_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")).to have_been_made
          expect(page).to have_content(I18n.t("requests.account.auth_user_lookup_fail"))
        end
      end

      context 'A Princeton net ID user without a bibdata record' do
        let(:user) { FactoryGirl.create(:user) }
        before do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
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
        it 'displays a request form for a ReCAP item.' do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
            .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
          login_as user
          visit "/requests/#{voyager_id}"
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_selector '#request_user_barcode', visible: false
          expect(page).to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
        end
      end

    context 'a princeton net ID user without a barcode' do
      let(:user) { FactoryGirl.create(:user) }
      let(:in_process_id) { '99121095223506421?mfhd=22183262530006421' }
      let(:recap_in_process_id) { '99105873133506421?mfhd=22251746380006421' }

      let(:recap_params) do
        {
          Bbid: "9994933183506421",
          item: "23131438400006421",
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

      context 'An undergraduate student who has not taken the training' do
        let(:user) { FactoryGirl.create(:user) }
        xit 'displays a request form for a ReCAP item.' do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
            .to_return(status: 200, body: valid_patron_no_campus_response, headers: {})
          login_as user
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_selector '#request_user_barcode', visible: false
          expect(page).to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
          expect(page).not_to have_content('If you would like to have access to pick-up books')
        end
      end

      describe 'When visiting a voyager ID as a CAS User' do
        xit 'allow CAS patrons to request an available ReCAP item.' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "9994933183506421", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                       requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, Requests.config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content('Physical Item Delivery')
          expect(page).to have_selector '#request_user_barcode', visible: false
          expect(page).not_to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
          expect(page).not_to have_content('If you would like to have access to pick-up books')
        end
      end

        it 'disallows access to in process items' do
          visit "/requests/#{in_process_id}"
          expect(page).not_to have_content 'Pick-up location: Marquand Library'
          expect(page).to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        xit 'Help Me Get it for in process recap items' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Robson, Alastair", "LoanTitle" => "Unrecognised by the world at large : a biography of Dr Henry Parsey, physician to the Hatton Asylum, Warwick", "LoanPublisher" => nil, "ISSN" => "9781788032728", "CallNumber" => nil, "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/99105873133506421", "ItemInfo3" => "", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Help Me Get It Request: User does not have access to physical item pickup"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit "/requests/#{recap_in_process_id}"
          expect(page).to have_content(I18n.t("requests.help_me.brief_msg.cas_user_no_barcode_no_choice_msg"))
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Help Me Get It Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("Unrecognised by the world at large : a biography of Dr Henry Parse")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'Help Me Get it for On-Order recap items' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Johnson, F. Neil", "LoanTitle" => "The declaration of war on Cleopatra : an examination of the evidence for the antiquity of the ceremony enacted by Octavian in the Campus Martius", "LoanPublisher" => nil, "ISSN" => "9781871622935", "CallNumber" => nil, "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/99120493093506421", "ItemInfo3" => "", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Help Me Get It Request: User does not have access to physical item pickup"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit "/requests/#{on_order_id}"
          expect(page).to have_content(I18n.t("requests.help_me.brief_msg.cas_user_no_barcode_no_choice_msg"))
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Help Me Get It Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("The declaration of war on Cleopatra ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'allows access to a record that has no item data' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "ISSN" => "9783905597363", "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9941274093506421", "PhotoJournalYear" => "2002", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand EDD", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "Location" => "Marquand Library - Marquand Library", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit "/requests/#{no_items_id}"
          # stub illiad
          expect(page).to have_button('Request this Item')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        xit 'allows access an on shelf record that has no item data to be digitized' do
          visit "/requests/#{on_shelf_no_items_id}"
          expect(page).to have_button('Request this Item')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_22261908670006421", with: "ABC ZZZ"
          within("#request_user_supplied_22261908670006421") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
            expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.to).to eq(["a@b.com"])
            expect(confirm_email.cc).to be_nil
            expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
            expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
          end

        it 'allows digitizing, but not pick-up of on on_shelf record' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Chekhov, Anton Pavlovich", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Pʹesy Пьесы", "PhotoItemPublisher" => "Moskva: Letniĭ sad", "ISSN" => "9785988562320", "CallNumber" => "PG3455 .A2 2015", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9997708113506421", "PhotoJournalYear" => "2015", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "964907363", "DocumentType" => "Book", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})

          stub_alma_hold_success('9997708113506421', '2268938710006421', '2268938710006421', '960594184')

          visit "/requests/9997708113506421?mfhd=2268938710006421"
          expect(page).not_to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Chekhov, Anton Pavlovich")
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        xit 'allows patrons to request a physical recap item' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "9999443553506421", callNumber: "DT549 .E274q Oversize", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101098722844"], itemOwningInstitution: "PUL", patronBarcode: '198572131', requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "L'écrivain, magazine litteraire trimestriel", username: "jstudent", volume: "2016"))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9999443553506421?mfhd=22202822560006421'
          expect(page).not_to have_content 'Pick-up location: '
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_23202822550006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("L'écrivain, magazine litteraire trimestriel")
        end

        it 'allows patrons to request a Forrestal annex' do
          visit '/requests/999455503506421?mfhd=2221072930006421'
          expect(page).not_to have_content 'Pick-up location: '
          expect(page).to have_content 'Electronic Delivery'
        end

        xit 'allows patrons to request a Lewis recap item digitally' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9970533073506421?mfhd=22214952010006421'
          expect(page).not_to have_content 'Available for In Library Use'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        end

        it 'allows patrons to request a digital copy from Lewis' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Alexakis, Spyros", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "The decomposition of global conformal invariants", "PhotoItemPublisher" => "Princeton: Princeton University Press", "ISSN" => "9780691153476 9780691153483", "CallNumber" => "QA646 .A44 2012", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9970533073506421", "PhotoJournalYear" => "2012", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "757838203", "DocumentType" => "Book", "Location" => "Lewis Library - Lewis Library (SCI)", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9970533073506421?mfhd=22214952030006421'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          choose('requestable__delivery_mode_23214952020006421_edd') # edd version
          within('#request_23214952020006421') do
            fill_in "Article/Chapter Title", with: "ABC"
          end
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted to Illiad'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        end

        it 'allows patrons to ask for digitizing on non circulating items' do
          visit '/requests/9995948403506421?mfhd=2258775160006421'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_css '.submit--request'
        end

        it 'allows filtering items by mfhd' do
          visit '/requests/9979171923506421?mfhd=22230315750006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'shows an error if MFHD is not present' do
          visit '/requests/9979171923506421'
          expect(page).not_to have_content 'Please Select a location on the main record page.'
        end

        it 'allow fillin forms in digital only' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => "", "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/99105746993506421", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})

          visit 'requests/99105746993506421?mfhd=22217601660006421'
          expect(page).to have_button('Request Selected Items')
          within("h3") do
            expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          end
          fill_in "requestable_user_supplied_enum_22217601660006421", with: "ABC ZZZ"
          within("#request_user_supplied_22217601660006421") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
          end
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        # TODO: once Marquad in library use is available again it should show pick-up at marquand also
        xit 'Shows ReCAP marqaund as an EDD option only' do
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/99117809653506421?mfhd=22203397510006421'
          choose('requestable__delivery_mode_23203397500006421_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Article/Chapter Title (Required)'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(email.html_part.body.to_s).to have_content("You will receive an email including a link where you can download your scanned section")
        end

        it "shows items in the Architecture Library as available" do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Steele, James", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory", "PhotoItemPublisher" => "New York, NY: The American University...", "ISSN" => "9789774168901", "CallNumber" => "NA1585.A23 S7 2020", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/99117876713506421", "PhotoJournalYear" => "2020", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1137152638", "DocumentType" => "Book", "Location" => "Architecture Library - Architecture Library", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/99117876713506421?mfhd=22196862260006421'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).not_to have_content 'Pick-up location: Architecture Library'
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business")
          expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
        end

        xit "disallows requests of recap pick-up only items" do
          visit '/requests/99115783193506421?mfhd=22155047580006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'allows aeon requests for all users' do
          visit '/requests/9973529363506421?mfhd=22111313200006421'
          expect(page).to have_content 'Request to View in Reading Room'
        end

        it 'allows guest patrons to see there are no items for Online only' do
          visit '/requests/9999946923506421?mfhd=22131438430006421'
          expect(page).to have_content 'there are no requestable items for this record'
        end

        it 'Help Me Get It instead of using Borrow Direct, ILL, and Recall on Missing items' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Help Me Get It Request: User does not have access to physical item pickup"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9917887963506421?mfhd=22196156490006421'
          expect(page).to have_content(I18n.t("requests.help_me.brief_msg.cas_user_no_barcode_no_choice_msg"))
          check "requestable_selected_23196156480006421"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Help Me Get It Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'allows generic fill in requests enums from Annex or Firestone in mixed holding' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Birth control news", "PhotoItemPublisher" => "", "ISSN" => "", "CallNumber" => "HQ766 .B53", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9922868943506421", "PhotoJournalYear" => "1000", "PhotoJournalVolume" => "ABC ZZZ", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "53175640", "DocumentType" => "Book", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9922868943506421?mfhd=22109192590006421'
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_22109192590006421'
          expect(page).to have_content 'Electronic Delivery'

          expect(page).to have_button('Request Selected Items')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_22109192590006421", with: "ABC ZZZ"
          within("#request_user_supplied_22109192590006421") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
          end

        it 'allows a non circulating item with not item data to be digitized' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                       "Location" => "Marquand Library - Marquand Library", "ISSN" => "9783905597363", "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog-alma-qa.princeton.edu/catalog/9941274093506421", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand EDD", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9941274093506421?mfhd=22197827810006421'
          expect(page).to have_content 'Electronic Delivery'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end
      end
    end # close everything for the alma migration
  end
  # rubocop:enable RSpec/MultipleExpectations
end
# rubocop:enable Metrics/BlockLength
