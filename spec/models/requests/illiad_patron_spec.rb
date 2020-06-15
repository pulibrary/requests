require 'spec_helper'
require 'net/ldap'

describe Requests::IlliadPatron, type: :controller do
  let(:user_info) do
    {
      "user_name" => "Foo Request",
      "user_last_name" => "Request",
      "user_first_name" => "Test",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch",
      "patron_id" => "9999",
      "netid" => "123abc",
      "patron_group" => "staff"
    }
  end

  let(:illiad_patron) { described_class.new(user_info) }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_found: '{"Message":"User abc123 was not found."}',
      outstanding_ill: '[{"TransactionNumber":1092880,"Username":"abc123","RequestType":"Loan","LoanAuthor":"Cornelis, Bart","LoanTitle":"TEST Adriaen van de Velde : Dutch master of landscape","LoanPublisher":"London: Paul Holberton Publishing","LoanPlace":null,"LoanDate":"2016","LoanEdition":null,"PhotoJournalTitle":null,"PhotoJournalVolume":null,"PhotoJournalIssue":null,"PhotoJournalMonth":null,"PhotoJournalYear":null,"PhotoJournalInclusivePages":null,"PhotoArticleAuthor":null,"PhotoArticleTitle":null,"CitedIn":"https://catalog.princeton.edu/catalog/9741216","CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":"COVID-19 Campus Closure","NotWantedAfter":"12/07/2020","AcceptNonEnglish":true,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Cancelled by ILL Staff","TransactionDate":"2020-06-12T09:31:08.28","ISSN":"9781907372964","ILLNumber":null,"ESPNumber":"932386459","LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,' \
        '"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":"ND653.V414 A4 2016","Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":"Book","InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"No","WantedBy":"Yes, until the semester\'s","SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,' \
        '"CancellationCode":null,"BillingCategory":null,"CCSelected":"No","OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":"LoanRequest","TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":"","CreationDate":"2020-06-10T14:52:08.807","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecialInstructions":null,"SpecialService":null,"DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null},{"TransactionNumber":1092224,"Username":"abc123","RequestType":"Loan","LoanAuthor":"Chekhov, Anton Pavlovich","LoanTitle":"Pʹesy","LoanPublisher":"Moskva: Letniĭ sad","LoanPlace":null,"LoanDate":"2015","LoanEdition":null,"PhotoJournalTitle":null,"PhotoJournalVolume":null,"PhotoJournalIssue":null,' \
        '"PhotoJournalMonth":null,"PhotoJournalYear":null,"PhotoJournalInclusivePages":null,"PhotoArticleAuthor":null,"PhotoArticleTitle":null,"CitedIn":"https://catalog.princeton.edu/catalog/9770811","CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":"COVID-19 Campus Closure","NotWantedAfter":"12/05/2020","AcceptNonEnglish":true,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Cancelled by ILL Staff","TransactionDate":"2020-06-10T16:13:57.48","ISSN":"9785988562320","ILLNumber":null,"ESPNumber":"964907363","LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":"PG3455 .A2 2015","Location":"F","Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,' \
        '"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":"Book","InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"No","WantedBy":"Yes, until the semester\'s","SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":"No","OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":"LoanRequest","TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,' \
        '"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":"","CreationDate":"2020-06-08T11:33:05.923","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecialInstructions":null,"SpecialService":null,"DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null},{"TransactionNumber":1093597,"Username":"abc123","RequestType":"Loan","LoanAuthor":"Chekhov, Anton Pavlovich","LoanTitle":"Pʹesy","LoanPublisher":"Moskva: Letniĭ sad","LoanPlace":null,"LoanDate":"2015","LoanEdition":null,"PhotoJournalTitle":null,"PhotoJournalVolume":null,"PhotoJournalIssue":null,"PhotoJournalMonth":null,"PhotoJournalYear":null,"PhotoJournalInclusivePages":null,"PhotoArticleAuthor":null,"PhotoArticleTitle":null,"CitedIn":"https://catalog.princeton.edu/catalog/9770811","CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":"COVID-19 Campus Closure","NotWantedAfter":"12/12/2020","AcceptNonEnglish":true,"AcceptAlternateEdition":true,' \
        '"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T09:36:39","ISSN":"9785988562320","ILLNumber":null,"ESPNumber":"964907363","LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":"PG3455 .A2 2015","Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":"Book","InternalAcctNo":null,"PriorityShipping":null,"Rush":null,"CopyrightAlreadyPaid":"No","WantedBy":"Yes, until the semester\'s","SystemID":null,"ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,' \
        '"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":"No","OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":"LoanRequest","TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T09:36:39.643","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecialInstructions":null,"SpecialService":null,"DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}]',
      client_created: '{"UserName":"123abc","ExternalUserId":"123abc","LastName":"User","FirstName":"Test","SSN":"99999999999","Status":"staff","EMailAddress":"123abc@test.com","Phone":"609-258-1378","Department":"Library - Information Technology","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-06-24T10:56:24.55","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"Firestone Library","Address2":"Library Information Technology","City":"Princeton","State":"NJ","Zip":"08544","Site":"Firestone","ExpirationDate":"2021-06-24T10:56:24.55","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      user_already_exits: '{"Message":"The request is invalid.","ModelState":{"UserName":["Username 123abc already exists."]}}'
    }
  end

  describe '#illiad_patron' do
    let(:stub_url_base) do
      "#{illiad_patron.illiad_api_base}/ILLiadWebPlatform/Users"
    end

    let(:stub_url) do
      "#{stub_url_base}/#{user_info['netid']}"
    end

    it "captures when user is not present" do
      stub_request(:get, stub_url)
        .to_return(status: 404, body: responses[:not_found], headers: {})
      expect(illiad_patron.illiad_patron).to be_blank
    end

    it "captures connection exceptions" do
      stub_request(:get, stub_url).and_raise(Faraday::ConnectionFailed, "failed")
      expect(illiad_patron.illiad_patron).to be_blank
    end

    it "returns data when user is present" do
      stub_request(:get, stub_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      patron = illiad_patron.illiad_patron
      expect(patron).not_to be_blank
      expect(patron[:UserName]).to eq('abc234')
      expect(patron[:ExternalUserId]).to eq('123abc')
      expect(patron[:Cleared]).to eq('Yes')
    end

    # rubocop:disable RSpec/AnyInstance
    it "can create a patron" do
      ldap_data = [{ uid: ['123abc'], ou: ['"Library - Information Technology'], puinterofficeaddress: ['Firestone Library$Library Information Technology'], telephonenumber: ['123-456-7890'], sn: ['Doe'], givenname: ['Joe'], mail: ['joe@abc.com'] }]
      expect_any_instance_of(Net::LDAP).to receive(:search).with(filter: Net::LDAP::Filter.eq("uid", '123abc')).and_return(ldap_data)
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => '123abc', "ExternalUserId" => "123abc", "FirstName" => "Test", "LastName" => "Request", "EmailAddress" => "joe@abc.com", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "staff", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "\"Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 200, body: responses[:client_created], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).not_to be_blank
      expect(patron["UserName"]).to eq('123abc')
      expect(patron["ExternalUserId"]).to eq('123abc')
      expect(patron["Cleared"]).to eq('Yes')
    end

    it "ignores client already exists when creating a patron" do
      ldap_data = [{ uid: ['123abc'], ou: ['"Library - Information Technology'], puinterofficeaddress: ['Firestone Library$Library Information Technology'], telephonenumber: ['123-456-7890'], sn: ['Doe'], givenname: ['Joe'], mail: ['joe@abc.com'] }]
      expect_any_instance_of(Net::LDAP).to receive(:search).with(filter: Net::LDAP::Filter.eq("uid", '123abc')).and_return(ldap_data)
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => '123abc', "ExternalUserId" => "123abc", "FirstName" => "Test", "LastName" => "Request", "EmailAddress" => "joe@abc.com", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "staff", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "\"Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 400, body: responses[:user_already_exits], headers: {})
      stub_request(:get, stub_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).not_to be_blank
      expect(patron[:UserName]).to eq('abc234')
      expect(patron[:ExternalUserId]).to eq('123abc')
      expect(patron[:Cleared]).to eq('Yes')
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
