require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :none }, type: :feature do
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

    let(:patron_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/jstudent" }
    let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
    let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:valid_patron_no_barcode_response) { fixture('/bibdata_patron_no_barcode_response.json') }
    let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
    let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

    let(:responses) do
      {
        found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
        transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                            '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                            '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
        note_created: '{"Message":"An error occurred adding note to transaction 1093946"}'
      }
    end

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
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "9493318", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                       requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, Requests.config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          # some weird issue with this and capybara examining the page source shows it is there.
          expect(page).to have_selector '#request_user_barcode', visible: false
          choose('requestable__delivery_mode_7303228_print') # chooses 'print' radio button
          select('Firestone Library', from: 'requestable__pickup')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content I18n.t("requests.submit.recap_success")
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("ʻAwāṭif madfūnah")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'does display the online access message' do
          visit "/requests/#{online_id}"
          expect(page).to have_content 'Online'
        end

        it 'allows CAS patrons to request In-Process items and can only be delivered to their holding library' do
          visit "/requests/#{in_process_id}"
          expect(page).to have_content 'In Process'
          expect(page).to have_content 'Pick-up location: Marquand Library'
          expect(page).to have_button('Request this Item', disabled: false)
          click_button 'Request this Item'
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
        end

        it 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere' do
          visit "/requests/#{recap_in_process_id}"
          expect(page).to have_content 'In Process'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pickup')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pickup')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pickup')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("In Process Request")
          expect(email.to).to eq(["fstcirc@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("Karşılaştırmalı mitoloji : Tolkien ne yaptı?")
          expect(confirm_email.subject).to eq("In Process Request")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Karşılaştırmalı mitoloji : Tolkien ne yaptı?")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

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
          expect(email.html_part.body.to_s).to have_content("3D thinking in design and architecture")
          expect(confirm_email.subject).to eq("On Order Request")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("3D thinking in design and architecture")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'allows CAS patrons to request a record that has no item data' do
          visit "/requests/#{no_items_id}"
          check('requestable__selected', exact: true)
          fill_in 'requestable[][user_supplied_enum]', with: 'Some Volume'
          expect(page).to have_button('Request Selected Items', disabled: false)
        end

        it 'allows CAS patrons to locate an on_shelf record that has no item data' do
          visit "/requests/#{on_shelf_no_items_id}"
          choose('requestable__delivery_mode_342_print') # chooses 'print' radio button
          select('Firestone Library', from: 'requestable__pickup')
          expect(page).to have_content "ReCAP Paging Request"
          expect(page).to have_content "Pick-up location: Firestone Library"
          # temporary changes 438
          # expect(page).to have_content 'Help Me Get It' # while recap is closed
          # expect(page).to have_link('Where to find it')
        end

        it 'allows CAS patrons to locate an on_shelf record' do
          stub_voyager_hold_success('9770811', '7502706', '77777')

          visit "/requests/9770811"
          expect(page).to have_content 'Pick-up location: Firestone Library'
          choose('requestable__delivery_mode_7502706_print') # chooses 'print' radio button
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
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
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'displays an ark link for a plum item' do
          visit "/requests/#{iiif_manifest_item}"
          expect(page).to have_link('Digital content', href: "https://catalog.princeton.edu/catalog/#{iiif_manifest_item}#view")
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        it 'allows patrons to request a physical recap item' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "9944355", callNumber: "Oversize DT549 .E274q", chapterTitle: "ABC", deliveryLocation: "PA", emailAddress: "a@b.com", endPage: "", issue: "",
                                       itemBarcodes: ["32101098722844"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "L'écrivain, magazine litteraire trimestriel", username: "jstudent", volume: "2016"))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9944355'
          expect(page).to have_content 'Electronic Delivery'
          select('Firestone Library', from: 'requestable__pickup')
          choose('requestable__delivery_mode_7467161_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("L'écrivain, magazine litteraire trimestriel")
        end

        it 'allows patrons to request a Forrestal annex' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/945550'
          choose('requestable__delivery_mode_1184074_print') # chooses 'print' radio button
          # todo: should we still have the text?
          # expect(page).to have_content 'Item offsite at Forrestal Annex. Requests for pick-up'
          expect(page).to have_content 'Electronic Delivery'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pickup')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pickup')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pickup')
          select('Firestone Library', from: 'requestable__pickup')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content 'Request submitted'
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Annex Request")
          expect(email.to).to eq(["forranx@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
          expect(confirm_email.subject).to eq("Annex Request")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'allows patrons to request a Lewis recap item digitally' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7053307?mfhd=6962326'
          # TODO: once Lewis opens, need to choose edd
          # choose('requestable__delivery_mode_6357449_edd') # chooses 'edd' radio button
          expect(page).not_to have_content 'Pick-up'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'allows patrons to request a Lewis' do
          stub_voyager_hold_success('7053307', '6322174', '77777')
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7053307'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          check 'requestable_selected_6322174'
          # temporary change issue 438
          # choose('requestable__delivery_mode_6322174_print') # chooses 'edd' radio button
          # select('Firestone Library', from: 'requestable__pickup')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content 'Item has been requested for pick-up'
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (SCI) QA646 .A44 2012")
          expect(email.to).to eq(["lewislib@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
          expect(confirm_email.subject).to eq("Lewis Library Pick-up Request")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
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

        it 'allows patrons to ask for digitizing on non circulating items' do
          visit '/requests/9594840'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_css '.submit--request'
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
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192?mfhd=7699134'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'show all copies if MFHD is not present' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_content 'Copy 2'
          expect(page).to have_content 'Copy 3'
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a print copy' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit 'requests/10574699'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_10320354", with: "ABC ZZZ"
          choose('requestable__delivery_mode_10320354_print') # choose the print radio button
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
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a electronic copy' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => nil, "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/10574699", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ",
                                       "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit 'requests/10574699'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_10320354", with: "ABC ZZZ"
          choose('requestable__delivery_mode_10320354_edd') # choose the print radio button
          fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        # TODO: once Marquad in library use is available again it should show pickup at marquand also
        it 'Shows marqaund as an EDD option only' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11780965?mfhd=11443781'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
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
          stub_voyager_hold_success('11787671', '8307797', '77777')
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11787671'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Pick-up location: Architecture Library'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (UESNB) NA1585.A23 S7 2020")
          expect(email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
          expect(confirm_email.subject).to eq("Architecture Library Pick-up Request")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it "allows requests of recap pickup only items" do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: nil, bibId: "11578319", callNumber: "DVD", chapterTitle: nil, deliveryLocation: "PA", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["32101108035435"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "Chernobyl : a 5-part miniseries", username: "jstudent", volume: nil))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11578319?mfhd=11259604'
          expect(page).not_to have_content 'Item is not requestable.'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).to have_content 'Item off-site at ReCAP facility. Request for delivery in 1-2 business days.'
          select('Firestone Library', from: 'requestable__pickup')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Chernobyl : a 5-part miniseries")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'allows cas patrons to see aeon requests' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/336525'
          expect(page).to have_content 'Request to View in Reading Room'
        end

        it 'allows guest patrons to access Online items' do
          visit '/requests/9994692'
          expect(page).to have_content 'www.jstor.org'
        end

        it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
          visit '/requests/1788796?mfhd=2053005'
          expect(page).to have_content 'Item is not requestable.'
        end

        it 'allows cas user to request from Annex or Firestone in mixed holding' do
          visit '/requests/2286894'
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_selected_7484608', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_2576882'
          within('#request_user_supplied_2576882') do
            check('requestable__selected', exact: true)
            fill_in 'requestable_user_supplied_enum_2576882', with: 'test'
          end
          select('Firestone Library', from: 'requestable__pickup')
          click_button 'Request Selected Items'
          expect(page).to have_content I18n.t('requests.submit.annexa_success')
        end

        it 'allows a non circulating item with not item data to be digitized' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                       "Location" => "Marquand Library", "ISSN" => nil, "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/4127409", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/4127409?mfhd=4403772'
          expect(page).to have_content 'Electronic Delivery'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
        end

        it 'allows an etas item to be digitized' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Edwards, Ruth Dudley", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "James Connolly", "PhotoItemPublisher" => "Dublin: Gill and Macmillan", "ISSN" => nil, "CallNumber" => "DA965.C7 E36 1981", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/162632", "PhotoJournalYear" => "1981", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "8391816", "DocumentType" => "Book", "Location" => "Online - HathiTrust Emergency Temporary Access", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/162632'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Online- HathiTrust Emergency Temporary Access DA965.C7 E36 1981'
          expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("James Connolly")
        end

        it "Shows help me get it for recap etas" do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "7599", callNumber: "PJ3002 .S4", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101073604215"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Semitistik", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7599'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).to have_content 'Online- HathiTrust Emergency Temporary Access PJ3002 .S4'
          expect(page).not_to have_content I18n.t("requests.recap_edd.note_msg")
          expect(page).to have_content 'Help Me Get It'
          expect(page).not_to have_content 'On-Site'
        end

        it "allows a columbia item that is not in hathi etas to be picked up or digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=21154437")
            .to_return(status: 200, body: '[]')
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "SCSB-2879197", callNumber: "PG3479.3.I84 Z778 1987g", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU01805363"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879197'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497908_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP PG3479.3.I84 Z778 1987g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it "allows a columbia item that is open access to be picked up or digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=502557695")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"502557695","bibid":"3863391","status":"ALLOW","origin":"CUL"}]')
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "SCSB-4634001", callNumber: "4596 2907.88 1901", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU51481294"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Chong wen men shang shui ya men xian xing shui ze. 崇文門 商稅 衙門 現行 稅則.", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-4634001'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_6826565_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP 4596 2907.88 1901'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content(" Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Chong wen men shang shui ya men xian xing shui ze")
          expect(confirm_email.html_part.body.to_s).to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it "allows a columbia item that is ETAS to only be digitized" do
          stub_request(:get, "#{Requests.config[:bibdata_base]}/hathi/access?oclc=19774500")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"19774500","bibid":"1000066","status":"DENY","origin":"CUL"}]')
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "SCSB-2879206", callNumber: "ML3477 .G74 1989g", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU61436348"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Let's face the music : the golden age of popular song", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879206'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497920_edd') # chooses 'edd' radio button
          fill_in "Article/Chapter Title", with: "ABC"
          expect(page).to have_content 'ReCAP ML3477 .G74 1989g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
          expect(confirm_email.html_part.body.to_s).to have_content("Let's face the music : the golden age of popular song")
          expect(confirm_email.html_part.body.to_s).to have_content("ABC")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it "Shows a Appointment link for a marquand in library use item" do
          visit '/requests/5636487'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_link('make an appointment', href: "https://libcal.princeton.edu/seats?lid=10656")
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

    context 'a princeton net ID user without a barcode' do
      let(:user) { FactoryGirl.create(:user) }
      let(:in_process_id) { '11543235' }
      let(:recap_in_process_id) { '11521583' }

      let(:recap_params) do
        {
          Bbid: "9493318",
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
          .to_return(status: 200, body: valid_patron_no_barcode_response, headers: {})
        login_as user
      end

      describe 'When visiting a voyager ID as a CAS User' do
        it 'allow CAS patrons to request an available ReCAP item.' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "9493318", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                       requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, Requests.config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          visit "/requests/#{voyager_id}"
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
        end

        it 'does display the online access message' do
          visit "/requests/#{online_id}"
          expect(page).to have_content 'Online'
        end

        it 'disallows access to in process items' do
          visit "/requests/#{in_process_id}"
          expect(page).not_to have_content 'Pick-up location: Marquand Library'
          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'disallows access to in process recap items' do
          visit "/requests/#{recap_in_process_id}"

          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'disallows access to  On-Order items' do
          visit "/requests/#{on_order_id}"
          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'allows access to a record that has no item data' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Maryland", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "An act to secure fair elections in Maryland", "PhotoItemPublisher" => "n.p.", "ISSN" => nil, "CallNumber" => "P94.849.036.15", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/3018567", "PhotoJournalYear" => "", "PhotoJournalVolume" => "ABC ZZZ", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "27412908", "DocumentType" => "Book", "Location" => "Forrestal Annex - Princeton Collection", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit "/requests/#{no_items_id}"
          # stub illiad
          expect(page).to have_button('Request Selected Items')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_3334792", with: "ABC ZZZ"
          fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
          check "requestable__selected"
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'allows access an recap record that has no item data to be digitized' do
          visit "/requests/#{on_shelf_no_items_id}"
          expect(page).to have_button('Request Selected Items')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_341", with: "ABC ZZZ"
          within("#request_user_supplied_341") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
          end
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("ReCAP Non-Barcoded Request.")
          expect(email.to).to eq(["recapproblems@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to eq([])
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'allows digitizing, but not pick up of on on_shelf record' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Chekhov, Anton Pavlovich", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Pʹesy Пьесы", "PhotoItemPublisher" => "Moskva: Letniĭ sad", "ISSN" => nil, "CallNumber" => "PG3455 .A2 2015", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9770811", "PhotoJournalYear" => "2015", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "964907363", "DocumentType" => "Book", "Location" => "Firestone Library", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})

          stub_voyager_hold_success('9770811', '7502706', '77777')

          visit "/requests/9770811"
          expect(page).not_to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Chekhov, Anton Pavlovich")
        end

        it 'displays an ark link for a plum item' do
          visit "/requests/#{iiif_manifest_item}"
          expect(page).to have_link('Digital content', href: "https://catalog.princeton.edu/catalog/#{iiif_manifest_item}#view")
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        it 'allows patrons to request a physical recap item' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .with(body: hash_including(author: "", bibId: "9944355", callNumber: "Oversize DT549 .E274q", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101098722844"], itemOwningInstitution: "PUL", patronBarcode: '198572131', requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "L'écrivain, magazine litteraire trimestriel", username: "jstudent", volume: "2016"))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9944355'
          expect(page).not_to have_content 'Pick-up location: '
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_7467161_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("L'écrivain, magazine litteraire trimestriel")
        end

        it 'allows patrons to request a Forrestal annex' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/945550'
          expect(page).not_to have_content 'Pick-up location: '
          expect(page).to have_content 'Electronic Delivery'
        end

        it 'allows patrons to request a Lewis recap item digitally' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7053307?mfhd=6962326'
          expect(page).not_to have_content 'Pick-up'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask or face covering")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Please do not use disinfectant or cleaning product on books")
        end

        it 'allows patrons to request a digital copy from Lewis' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Alexakis, Spyros", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "The decomposition of global conformal invariants", "PhotoItemPublisher" => "Princeton: Princeton University Press", "ISSN" => nil, "CallNumber" => "QA646 .A44 2012", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/7053307", "PhotoJournalYear" => "2012", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "757838203", "DocumentType" => "Book", "Location" => "Lewis Library", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/7053307'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          within('#request_6322174') do
            fill_in "Article/Chapter Title", with: "ABC"
          end
          check 'requestable_selected_6322174'
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Request submitted to Illiad'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        end

        it 'allows patrons to ask for digitizing on non circulating items' do
          visit '/requests/9594840'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_css '.submit--request'
        end

        it 'allows filtering items by mfhd' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192?mfhd=7699134'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'show all copies if MFHD is not present' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/7917192'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Copy 2'
          expect(page).to have_content 'Copy 3'
        end

        it 'allow fillin forms in digital only' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => nil, "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/10574699", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})

          visit 'requests/10574699'
          expect(page).to have_button('Request this Item')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_10320354", with: "ABC ZZZ"
          within("#request_user_supplied_10320354") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
          end
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        # TODO: once Marquad in library use is available again it should show pickup at marquand also
        it 'Shows marqaund as an EDD option only' do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/11780965?mfhd=11443781'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
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
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Steele, James", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory", "PhotoItemPublisher" => "New York, NY: The American University...", "ISSN" => nil, "CallNumber" => "NA1585.A23 S7 2020", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/11787671", "PhotoJournalYear" => "2020", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1137152638", "DocumentType" => "Book", "Location" => "Architecture Library - New Book Shelf", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/11787671'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).not_to have_content 'Pick-up location: Architecture Library'
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business")
          expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
        end

        it "disallows requests of recap pickup only items" do
          visit '/requests/11578319?mfhd=11259604'
          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'disallows aeon requests' do
          visit '/requests/336525'
          expect(page).not_to have_content 'Request to View in Reading Room'
        end

        it 'allows guest patrons to access Online items' do
          visit '/requests/9994692'
          expect(page).to have_content 'www.jstor.org'
        end

        it 'prohibits using Borrow Direct, ILL, and Recall on Missing items' do
          visit '/requests/1788796?mfhd=2053005'
          expect(page).not_to have_button('Request this Item')
          expect(page).to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
        end

        it 'allows generic fill in requests enums from Annex or Firestone in mixed holding' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Birth control news", "PhotoItemPublisher" => "", "ISSN" => nil, "CallNumber" => "HQ766 .B53f", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/2286894", "PhotoJournalYear" => "1000", "PhotoJournalVolume" => "ABC ZZZ", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "53175640", "DocumentType" => "Book", "Location" => "Forrestal Annex - Locked Books", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/2286894'
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_selected_7484608', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_2576882'
          expect(page).to have_content 'Electronic Delivery'

          expect(page).to have_button('Request Selected Items')
          expect(page).not_to have_content(I18n.t("requests.account.cas_user_no_barcode_no_choice_msg"))
          fill_in "requestable_user_supplied_enum_2576882", with: "ABC ZZZ"
          within("#request_user_supplied_2576882") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
            check "requestable__selected"
          end
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Wear a mask")
        end

        it 'allows a non circulating item with not item data to be digitized' do
          stub_request(:get, patron_url)
            .to_return(status: 200, body: responses[:found], headers: {})
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                       "Location" => "Marquand Library", "ISSN" => nil, "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/4127409", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/4127409?mfhd=4403772'
          expect(page).to have_content 'Electronic Delivery'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
