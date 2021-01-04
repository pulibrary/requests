require 'spec_helper'

describe Requests::RequestDecorator do
  subject(:decorator) { described_class.new(request, view_context) }
  let(:user) { FactoryGirl.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: ldap }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: user, session: {}, patron: valid_patron) }

  let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
  let(:request) do
    instance_double(Requests::Request, system_id: '123abc', ctx: solr_context, requestable: [requestable], patron: patron, first_filtered_requestable: requestable,
                                       display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', filtered_sorted_requestable: { "112233" => [requestable] }, sorted_requestable: { "112233" => [requestable] })
  end
  let(:solr_context) { instance_double(Requests::SolrOpenUrlContext) }
  let(:stubbed_questions) { { etas?: false } }
  let(:ldap) { {} }
  let(:view_context) { ActionView::Base.new }

  describe "#bib_id" do
    it 'is the system id' do
      expect(decorator.bib_id).to eq('123abc')
    end
  end

  describe "#catalog_url" do
    it 'points to the catalog' do
      expect(decorator.catalog_url).to eq('/catalog/123abc')
    end
  end

  describe "#patron_message" do
    it 'shows the message for the campus unauthorized patron' do
      expect(decorator.patron_message).to eq "<div class='alert alert-warning'>You are not currently authorized for on-campus services at the Library. Please consult with your Department if you believe you should have access to these services.</div>"
    end

    context "staff ldap status" do
      let(:ldap) { { status: 'staff' } }
      it 'shows the message for the campus unauthorized patron' do
        expect(decorator.patron_message).to eq "<div class='alert alert-warning'>You are not currently authorized for on-campus services at the Library. Please consult with your Department if you believe you should have access to these services.  If you would like to have access to pick-up books <a href='https://ehs.princeton.edu/COVIDTraining'>please complete the mandatory COVID-19 training</a>.</div>"
      end
    end

    context "staff with access to campus" do
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap, campus_authorized: true }.with_indifferent_access
      end

      it 'shows the message for the campus authorized patron' do
        expect(decorator.patron_message).to eq ""
      end
    end
    context "an etas record" do
      let(:stubbed_questions) { { etas?: true, etas_limited_access: false } }
      it 'shows the message for the etas items' do
        expect(decorator.patron_message).to eq "<div class='alert alert-warning'>We currently cannot lend this item, but you may view an online copy via the <a href='/catalog/123abc'>link in the record page</a></div>"
      end
    end

    context "an etas recap record" do
      let(:stubbed_questions) { { etas?: true, etas_limited_access: true } }
      it 'shows the message for the etas items' do
        expect(decorator.patron_message).to eq "<div class='alert alert-warning'>We currently cannot lend this item from our ReCAP partner collection due to changes in copyright restrictions.</div>"
      end
    end
  end

  describe "#hidden_fields" do
    it "shows all display metdata" do
      expect(decorator.hidden_fields).to eq('<input type="hidden" name="bib[id]" id="bib_id" value="123abc" /><input type="hidden" name="bib[title]" id="bib_title" value="title" /><input type="hidden" name="bib[author]" id="bib_author" value="author" /><input type="hidden" name="bib[isbn]" id="bib_isbn" value="isbn" />')
    end
  end

  describe "#format_brief_record_display" do
    it "shows all display metadata" do
      expect(decorator.format_brief_record_display).to eq('<dl class="dl-horizontal"><dt>Title</dt><dd lang="en" id="title">t</dd><dt>Author/Artist</dt><dd lang="en" id="authorartist">a</dd></dl>')
    end
  end

  describe "#fill_in_eligible" do
    context "recap services" do
      let(:stubbed_questions) { { etas?: false, services: ['recap', 'recap_edd'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_falsey
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_truthy
      end
    end

    context "on_shelf services with no item data and does not circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: false } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_falsey
      end
    end

    context "on_shelf services with item data that is not enumerated" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: true, circulates?: false, item: Requests::Requestable::Item.new({}) } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_falsey
      end
    end

    context "on_shelf services with item data that is enumerated" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: true, circulates?: false, item: Requests::Requestable::Item.new('enum' => true) } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_truthy
      end
    end

    context "on_order services" do
      let(:stubbed_questions) { { etas?: false, services: ['on_order'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.fill_in_eligible("112233")).to be_falsey
      end
    end
  end

  describe "#any_fill_in_eligible?" do
    context "recap services" do
      let(:stubbed_questions) { { etas?: false, services: ['recap', 'recap_edd'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_truthy
      end
    end
  end

  describe "#any_will_submit_via_form?" do
    context "recap services" do
      let(:stubbed_questions) { { etas?: false, services: ['recap', 'recap_edd'], will_submit_via_form?: true, item_data?: true, recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: true, eligible_to_pickup?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, user_barcode: '111222', ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it "submits via form" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: false, recap_edd?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, user_barcode: '111222', ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it "does not submit via form" do
        expect(decorator.any_will_submit_via_form?).to be_falsey
      end
    end
  end

  describe "#single_item_request?" do
    context "recap services" do
      let(:stubbed_questions) { { etas?: false, services: ['recap', 'recap_edd'] } }
      it "is a single item" do
        expect(decorator.single_item_request?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { etas?: false, services: ['on_shelf'], item_data?: false, circulates?: true } }
      it "is not a single item" do
        expect(decorator.single_item_request?).to be_falsey
      end
    end
  end
end
