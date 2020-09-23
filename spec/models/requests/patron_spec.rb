require 'spec_helper'

describe Requests::Patron do
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

  context 'When an access patron visits the site' do
    describe '#access_patron' do
      it 'creates an access patron with required access attributes' do
        patron = described_class.new(user: instance_double(User, guest?: true),
                                     session: { email: 'foo@bar.com', user_name: 'foobar' }.with_indifferent_access)
        expect(patron).to be_truthy
        expect(patron.active_email).to eq('foo@bar.com')
        expect(patron.last_name).to eq('foobar')
        expect(patron.barcode).to eq('ACCESS')
        expect(patron.campus_authorized).to be_falsey
      end
    end
  end
  context 'A user with a valid princeton net id patron record' do
    describe '#patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo")
          .to_return(status: 200, body: valid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'),
                                     session: { email: 'foo@bar.com', user_name: 'foobar' }.with_indifferent_access)
        expect(patron).to be_truthy
        expect(patron.active_email).to eq('a@b.com')
        expect(patron.netid).to eq('jstudent')
        expect(patron.campus_authorized).to be_truthy
      end
    end
  end
  context 'A user with a valid barcode patron record' do
    describe '#current_patron' do
      let(:user) { FactoryGirl.create(:valid_barcode_patron) }
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo")
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), session: {})
        expect(patron).to be_truthy
        expect(patron.active_email).to eq('a@b.com')
        expect(patron.netid).to be_nil
        expect(patron.campus_authorized).to be_falsey
      end
    end
  end
  context 'A user with a netid that does not have a matching patron record' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo")
          .to_return(status: 404, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), session: {})
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end
  context 'Cannot connect to Patron Data service' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo")
          .to_return(status: 403, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), session: {})
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end
  context 'System Error from Patron data service' do
    describe '#current_patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo")
          .to_return(status: 500, body: invalid_patron_response, headers: {})
      end
      it 'cannot return a patron record' do
        patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), session: {})
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end

  context 'Passing in patron information instead of loading it from bibdata' do
    it "does not call to bibdata" do
      patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), session: {}, patron: { barcode: "1234567890" })
      expect(patron.barcode).to eq('1234567890')
    end
  end
end
