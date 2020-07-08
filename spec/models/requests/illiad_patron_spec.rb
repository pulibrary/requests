require 'spec_helper'
require 'net/ldap'

describe Requests::IlliadPatron, type: :controller do
  let(:user_info) do
    {
      "netid" => "foo",
      "first_name" => "Foo",
      "last_name" => "Request",
      "barcode" => "22101007797777",
      "university_id" => "9999999",
      "patron_group" => "staff",
      "patron_id" => "99999",
      "active_email" => "foo@princeton.edu"
    }
  end

  let(:illiad_patron) { described_class.new(user_info) }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"foo","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_found: '{"Message":"User abc123 was not found."}',
      client_created: '{"UserName":"foo","ExternalUserId":"foo","LastName":"User","FirstName":"Test","SSN":"99999999999","Status":"staff","EMailAddress":"foo@test.com","Phone":"609-258-1378","Department":"Library - Information Technology","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-06-24T10:56:24.55","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"Firestone Library","Address2":"Library Information Technology","City":"Princeton","State":"NJ","Zip":"08544","Site":"Firestone","ExpirationDate":"2021-06-24T10:56:24.55","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      user_already_exits: '{"Message":"The request is invalid.","ModelState":{"UserName":["Username foo already exists."]}}'
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
      expect(patron[:ExternalUserId]).to eq('foo')
      expect(patron[:Cleared]).to eq('Yes')
    end

    # rubocop:disable RSpec/AnyInstance
    it "can create a patron" do
      ldap_data = [{ uid: ['foo'], ou: ['"Library - Information Technology'], puinterofficeaddress: ['Firestone Library$Library Information Technology'], telephonenumber: ['123-456-7890'], sn: ['Doe'], givenname: ['Joe'], mail: ['joe@abc.com'] }]
      expect_any_instance_of(Net::LDAP).to receive(:search).with(filter: Net::LDAP::Filter.eq("uid", 'foo')).and_return(ldap_data)
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "staff", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "\"Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 200, body: responses[:client_created], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).not_to be_blank
      expect(patron["UserName"]).to eq('foo')
      expect(patron["ExternalUserId"]).to eq('foo')
      expect(patron["Cleared"]).to eq('Yes')
    end

    it "ignores client already exists when creating a patron" do
      ldap_data = [{ uid: ['foo'], ou: ['"Library - Information Technology'], puinterofficeaddress: ['Firestone Library$Library Information Technology'], telephonenumber: ['123-456-7890'], sn: ['Doe'], givenname: ['Joe'], mail: ['joe@abc.com'] }]
      expect_any_instance_of(Net::LDAP).to receive(:search).with(filter: Net::LDAP::Filter.eq("uid", 'foo')).and_return(ldap_data)
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "staff", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "\"Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 400, body: responses[:user_already_exits], headers: {})
      stub_request(:get, stub_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).not_to be_blank
      expect(patron[:UserName]).to eq('abc234')
      expect(patron[:ExternalUserId]).to eq('foo')
      expect(patron[:Cleared]).to eq('Yes')
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
