require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe Requests::RequestableDecorator do
  subject(:decorator) { described_class.new(requestable, view_context) }
  let(:user) { FactoryGirl.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: ldap }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: user, session: {}, patron: valid_patron) }

  let(:requestable) { instance_double(Requests::Requestable, stubbed_questions) }
  let(:stubbed_questions) { { etas?: false } }
  let(:view_context) { ActionView::Base.new }
  let(:ldap) { {} }

  describe "#digitize?" do
    let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true } }
    it 'can not be digitized' do
      expect(decorator.digitize?).to be_falsey
    end

    context "no item data and does not circulate and is recap_edd and not scsb_in_library_use and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'can be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, borrow_direct?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and in process" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and on order" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and is scsb_in_library_use" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is not recap_edd" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['on_shelf'], recap_edd?: false } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd is not on_shelf edd" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf'], recap_edd?: false } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd but is on_shelf edd and not on_order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'can be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate but is on_shelf edd and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and but is on_shelf edd and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is but is on_shelf edd and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and in process" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and on_order" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "with item data and does circulate and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and in process " do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and on order" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end
  end

  describe "#pick_up?" do
    let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true, eligible_to_pickup?: false } }
    it 'can not be picked up' do
      expect(decorator.pick_up?).to be_falsey
    end

    context "a user eligible to pick up" do
      context "not in etas and in_library_use_only" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and scsb_in_library_use" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and on_order? " do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and in_process? " do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and traceable" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas borrow_direct?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and ill_eligible?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas on_shelf" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas on_shelf_edd only" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf_edd'] } }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates not on shelf and recap? and in_library_use_only?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and scsb_in_library_use" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and on_order" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and in_process" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and traceable?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and borrow_direct?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and ill_eligible?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and recap" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['recap'] } }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates and annexa? and in_library_use_only" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and scsb_in_library_use?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and on_order" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and in_process" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and traceable" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and borrow_direct?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa? and ill_eligible?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annexa?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['annexa'] } }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates not on shelf and not recap? and not annexa?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: false } }
        it 'can be not picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "in etas" do
        let(:stubbed_questions) { { etas?: true, item_data?: false, circulates?: true, eligible_to_pickup?: true } }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end
    end
  end

  describe "#available_for_appointment?" do
    let(:stubbed_questions) { { circulates?: true } }
    it 'is not available for an appointment' do
      expect(decorator.available_for_appointment?).to be_falsey
    end

    context "does not circulate and in recap" do
      let(:stubbed_questions) { { circulates?: false, recap?: true } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end

    context "does not circulate and charged?" do
      let(:stubbed_questions) { { charged?: true, circulates?: false, recap?: false } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end

    context "does not circulate and not charged? and aeon?" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: true } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end

    context "does not circulate and not charged? and etas" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: true } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end

    context "at an open library does not circulate and not charged? and campus_authorized" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: false, campus_authorized: true, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it 'is available for an appointment' do
        expect(decorator.available_for_appointment?).to be_truthy
      end
    end

    context "at an closed library does not circulate and not charged? and campus_authorized" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: false, campus_authorized: true, open_libraries: ['def'], location: { library: { code: 'abc' } } } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end

    context "does not circulate and not charged? and not campus_authorized" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: false, campus_authorized: false } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end
  end

  describe "#located_in_an_open_library?" do
    let(:stubbed_questions) { { open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
    it 'is available for digitizing' do
      expect(decorator.located_in_an_open_library?).to be_truthy
    end

    context "located in an unopen library" do
      let(:stubbed_questions) { { open_libraries: ['abc', 'def'], location: { library: { code: '123' } } } }
      it 'is not available for digitizing' do
        expect(decorator.located_in_an_open_library?).to be_falsey
      end
    end
  end

  describe "#fill_in_digitize?" do
    let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true } }
    it 'can not be fill_in_digitize?' do
      expect(decorator.fill_in_digitize?).to be_truthy
    end

    context "no item data and does not circulate and is recap_edd and not scsb_in_library_use and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and aeon" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and in process" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and on order" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and is scsb_in_library_use" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: true } }
      it 'can not be not fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is not recap_edd" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['on_shelf'], recap_edd?: false } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate and is not recap_edd is not on_shelf edd" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf'], recap_edd?: false } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd but is on_shelf edd and not on_order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate but is on_shelf edd and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and but is on_shelf edd and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is but is on_shelf edd and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and in process" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and on_order" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does circulate and ill_eligible" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and borrow_direct" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and traceable" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and in process " do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and on order" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: true } }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end
  end

  describe "#fill_in_pick_up?" do
    let(:stubbed_questions) { { item_data?: false, eligible_to_pickup?: true } }
    it 'can be fill_in_pick_up?' do
      expect(decorator.fill_in_pick_up?).to be_truthy
    end

    context "eligible to pick up and item_data and etas" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
      it 'can be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_truthy
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and ill_eligible" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and borrow_direct" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and traceable" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and in_process" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and on_order" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and scsb_in_library_use" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: false, scsb_in_library_use?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and in_library_use_only" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, in_library_use_only?: true } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and does not circulate" do
      let(:stubbed_questions) { { item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: false } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "not eligible to pick up" do
      let(:stubbed_questions) { { eligible_to_pickup?: false } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "does not circulate" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, eligible_to_pickup?: false } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end
  end

  describe "#request?" do
    context "not eligible to pick up" do
      let(:stubbed_questions) { { eligible_to_pickup?: false } }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "eligible to pick up and any service" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "eligible to pick up and no services" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: [] } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and ill_eligible" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and borrow_direct" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and traceable" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and in_process?" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: false, in_process?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and on_order?" do
      let(:stubbed_questions) { { eligible_to_pickup?: true, on_order?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end
  end

  describe "#will_submit_via_form?" do
    let(:stubbed_questions) { item_flags.merge(user).merge(location).merge(service) }
    let(:item_flags) { { item_data?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
    let(:service) { { services: ["on_shelf", "on_shelf_edd"], on_shelf?: true } }
    let(:an_open_library) { { open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
    let(:a_closed_library) { { open_libraries: ['def'], location: { library: { code: 'abc' } } } }
    context "a pickup eligible user" do
      let(:user) { { user_barcode: '111222333', eligible_to_pickup?: true } }
      context "at an open library" do
        let(:location) { an_open_library }
        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { { item_data?: false, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will not be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { { item_data?: false, etas?: true, traceable?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { { item_data?: false, etas?: true, in_process?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { { item_data?: false, etas?: true, on_order?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
      context "at a closed library" do
        let(:location) { a_closed_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { { item_data?: false, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { { item_data?: false, etas?: true, traceable?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { { item_data?: false, etas?: true, in_process?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { { item_data?: false, etas?: true, on_order?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
    end
    context "a non pickup eligible user" do
      let(:user) { { user_barcode: nil, eligible_to_pickup?: false } }
      context "at an open library" do
        let(:location) { an_open_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            pending "not sure why this is not submitting..."
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { { item_data?: false, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will not be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { { item_data?: false, etas?: true, traceable?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { { item_data?: false, etas?: true, in_process?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { { item_data?: false, etas?: true, on_order?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
      context "at a closed library" do
        let(:location) { a_closed_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { { item_data?: false, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas" do
          let(:item_flags) { { item_data?: false, etas?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { { item_data?: false, etas?: true, traceable?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { { item_data?: false, etas?: true, in_process?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { { item_data?: false, etas?: true, on_order?: true, circulates?: true, in_library_use_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
    end

    context "no item data and does not circulate and etas and scsb_in_library_use" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: true } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, eligible_to_pickup?: true, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil, eligible_to_pickup?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and on order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and on order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and on order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and on order and no user bar code" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and scsb_in_library_use" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: true } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup?" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '11122233' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable and no user barcode " do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil, ask_me?: false, open_libraries: ['abc'], location: { library: { code: 'abc' } }, aeon?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and scsb_in_library_use?" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: true } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end
  end

  describe "#request_status?" do
    context "any service" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
      it 'can not be requested' do
        expect(decorator.request_status?).to be_falsey
      end
    end

    context "no services" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: [] } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "ill_eligible" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "borrow_direct" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "aeon?" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false, services: ['any'] } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_falsey
      end
    end

    context "traceable" do
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "in_process?" do
      let(:stubbed_questions) { { on_order?: false, in_process?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "on_order?" do
      let(:stubbed_questions) { { on_order?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end
  end

  describe "#libcal_url" do
    let(:stubbed_questions) { { etas?: false, circulates?: true } }
    it "does not return a url" do
      expect(decorator.libcal_url).to be_blank
    end

    context "an item that does not circulate and is recap" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: true } }
      it "does not return a url" do
        expect(decorator.libcal_url).to be_blank
      end
    end

    context "an item that does not circulate and not recap and charged" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: false, charged?: true } }
      it "does not return a url" do
        expect(decorator.libcal_url).to be_blank
      end
    end

    context "an item that does not circulate and not recap and not charged and aeon" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: false, charged?: false, aeon?: true } }
      it "does not return a url" do
        expect(decorator.libcal_url).to be_blank
      end
    end

    context "an item that does not circulate and not recap and not charged and not aeon and not campus authorized" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: false, charged?: false, aeon?: false, campus_authorized: false } }
      it "does not return a url" do
        expect(decorator.libcal_url).to be_blank
      end
    end

    context "an item at an open library that does not circulate and not recap and not aeon and not charged and campus authorized" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: false, charged?: false, aeon?: false, campus_authorized: true, location: { 'library' => { 'code' => 'firestone' } }, open_libraries: ['firestone'] }.with_indifferent_access }
      it "returns a url" do
        expect(decorator.libcal_url).to eq("https://libcal.princeton.edu/seats?lid=1919")
      end
    end
  end

  describe "#help_me_message" do
    let(:stubbed_questions) { { patron: patron, open_libraries: ['abc'], location: { library: { code: 'abc' } }, scsb_in_library_use?: false } }

    it "returns the unauthorized patron message" do
      expect(decorator.help_me_message).to eq("This item is only available for pick-up or in library use. Library staff will work to try to get you access to a digital copy of the desired material.")
    end

    context "trained patron" do
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap, campus_authorized: false, campus_authorized_category: "trained" }.with_indifferent_access
      end

      it "returns the trained patron message" do
        expect(decorator.help_me_message).to eq("This item is only available for use in the library. Library staff will work to try to get you access to a digital copy of the desired material.")
      end

      context "closed library" do
        let(:stubbed_questions) { { patron: patron, open_libraries: ['def'], location: { library: { code: 'abc' } } } }

        it "returns the correct message" do
          expect(decorator.help_me_message).to eq("This item is not accessible to any patron.  Library staff will work to try to get you access to a copy of the desired material.")
        end
      end

      context "scsb in library etas item" do
        let(:stubbed_questions) { { patron: patron, open_libraries: ['abc'], location: { library: { code: 'abc' } }, scsb_in_library_use?: true, etas?: true } }

        it "returns the correct message" do
          expect(decorator.help_me_message).to eq("This item is not accessible to any patron.  Library staff will work to try to get you access to a copy of the desired material.")
        end
      end
    end

    context "patron with full campus access" do
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap,
          campus_authorized: true }.with_indifferent_access
      end

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq("This item is not accessible to any patron.  Library staff will work to try to get you access to a copy of the desired material.")
      end
    end

    context "closed library" do
      let(:stubbed_questions) { { patron: patron, open_libraries: ['def'], location: { library: { code: 'abc' } } } }

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq("This item is not accessible to any patron.  Library staff will work to try to get you access to a copy of the desired material.")
      end
    end

    context "scsb in library etas item" do
      let(:stubbed_questions) { { patron: patron, open_libraries: ['abc'], location: { library: { code: 'abc' } }, scsb_in_library_use?: true, etas?: true } }

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq("This item is not accessible to any patron.  Library staff will work to try to get you access to a copy of the desired material.")
      end
    end
  end

  describe "#aeon_url" do
    let(:ctx) { instance_double(Requests::SolrOpenUrlContext) }
    context "aeon voyager managed" do
      let(:stubbed_questions) do
        { services: ['lewis'], charged?: false, aeon?: true,
          voyager_managed?: true, ask_me?: false, aeon_request_url: 'aeon_link' }
      end
      it 'a link for reading room' do
        expect(decorator.aeon_url(ctx)).to eq('aeon_link')
      end
    end

    context "aeon NOT voyager managed" do
      let(:stubbed_questions) do
        { services: ['lewis'], charged?: false, aeon?: true,
          voyager_managed?: false, ask_me?: false, aeon_request_url: 'link',
          aeon_mapped_params: { abc: 123 } }
      end
      it 'a link for reading room' do
        expect(decorator.aeon_url(ctx)).to eq('https://library.princeton.edu/aeon/aeon.dll?abc=123')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
