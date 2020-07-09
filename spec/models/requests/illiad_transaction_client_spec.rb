require 'spec_helper'

describe Requests::IlliadTransactionClient, type: :controller do
  let(:user_info) do
    # TODO: net id will not come from the form we need to add it to the form
    { "user_name" => "Jane Smith", "user_last_name" => " Smith", "user_barcode" => "999999", "patron_id" => "99999", "patron_group" => "staff", "email" => "smith.jane@princeton.edu", "source" => "pulsearch", "netid" => "abc234" }
  end
  let(:requestable) do
    [{ "selected" => "true", "bibid" => "10921934", "mfhd" => "10637717", "call_number" => "HF1131 .B485",
       "location_code" => "f", "item_id" => "7892830", "barcode" => "32101102865654", "enum" => "2019",
       "copy_number" => "0", "status" => "Not Charged", "type" => "on_shelf", "pickup" => "PA",
       "edd_genre" => "journal", "edd_isbn" => "", "edd_date" => "", "edd_publisher" => "Santa Barbara, Calif: ABC-CLIO",
       "edd_call_number" => "HF1131 .B485", "edd_oclc_number" => "1033410889", "edd_title" => "Best business schools", "edd_note" => "Customer note" }]
    # {"selected"=>"true", "bibid"=>"3510207", "mfhd"=>"3832636", "call_number"=>"D25 .D385 1999",
    # "location_code"=>"f", "item_id"=>"3052428", "barcode"=>"32101044636858", "copy_number"=>"1",
    # "status"=>"Not Charged", "type"=>"on_shelf", "pickup"=>"PA"}
  end

  let(:bib) do
    { "id" => "3510207", "title" => "100 decisive battles : from ancient times to the present", "author" => "Davis, Paul K.",
      "isbn" => "9781576070758", "oclc_number" => "42579288", "date" => "1999" }
  end

  let(:params) do
    {
      request: user_info,
      requestable: requestable,
      bib: bib
    }
  end

  let(:submission) do
    Requests::Submission.new(params, user_info)
  end

  let(:illiad_transaction) { described_class.new(user: submission.user, bib: submission.bib, item: submission.items.first) }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_found: '{"Message":"User abc123 was not found."}',
      note: '{ "Note" : "Digitization Request", "NoteType" : "Staff" }',
      note_created: '{"Message":"An error occurred adding note to transaction 1093946"}',
      transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","LoanAuthor":null,"LoanTitle":null,"LoanPublisher":null,"LoanPlace":null,"LoanDate":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                           '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                           '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":null,"DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}'
    }
  end

  describe '#illiad_patron' do
    let(:patron_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/Users/#{user_info['netid']}" }
    let(:transaction_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction" }
    let(:transaction_note_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction/1093806/notes" }

    it "returns data when user is present" do
      stub_request(:get, patron_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      stub_request(:post, transaction_url)
        .with(body: hash_including("Username" => "abc234", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Davis, Paul K.", "LoanTitle" => "100 decisive battles : from ancient times to the present", "LoanPublisher" => "Santa Barbara, Calif: ABC-CLIO", "LoanDate" => nil, "ISSN" => "9781576070758", "CallNumber" => "HF1131 .B485", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/3510207", "PhotoJournalVolume" => nil,
                                   "PhotoJournalIssue" => nil, "ItemInfo3" => nil, "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1033410889", "DocumentType" => "Book", "PhotoArticleTitle" => nil))
        .to_return(status: 200, body: responses[:transaction_created], headers: {})
      stub_request(:post, transaction_note_url)
        .with(body: hash_including("Note" => "Digitization Request: Customer note"))
        .to_return(status: 200, body: responses[:note_created], headers: {})
      transaction = illiad_transaction.create_request
      expect(transaction).not_to be_blank
      expect(transaction["Username"]).to eq('abc123')
      expect(transaction["TransactionNumber"]).to eq(1_093_806)
    end
  end
end
