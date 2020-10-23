require 'spec_helper'

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
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and aeon" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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

    context "with item data and does not circulate and but is on_shelf edd and aeon" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false } }
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

    context "with item data and does circulate and aeon?" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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

      context "not in etas and aeon?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
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

      context "not in etas, has item data and circulates and aeon?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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

      context "not in etas, has item data and circulates and annexa? and aeon?" do
        let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annexa?: true, in_library_use_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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

    context "does not circulate and not charged? and campus_authorized" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: false, campus_authorized: true } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_truthy
      end
    end

    context "does not circulate and not charged? and not campus_authorized" do
      let(:stubbed_questions) { { charged?: false, circulates?: false, recap?: false, aeon?: false, etas?: false, campus_authorized: false } }
      it 'is not available for an appointment' do
        expect(decorator.available_for_appointment?).to be_falsey
      end
    end
  end

  describe "#available_for_digitizing?" do
    let(:stubbed_questions) { { open_libraries: ['abc'], location: { library: { code: 'abc' } } } }
    it 'is available for digitizing' do
      expect(decorator.available_for_digitizing?).to be_truthy
    end

    context "located in an unopen library" do
      let(:stubbed_questions) { { open_libraries: ['abc', 'def'], location: { library: { code: '123' } } } }
      it 'is not available for digitizing' do
        expect(decorator.available_for_digitizing?).to be_falsey
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

    context "with item data and does not circulate and but is on_shelf edd and aeon" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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

    context "with item data and does circulate and aeon?" do
      let(:stubbed_questions) { { etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
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
    let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true, user_barcode: '111222', covid_trained?: true } }
    it 'can be fill_in_pick_up?' do
      expect(decorator.fill_in_pick_up?).to be_truthy
    end

    context "no user barcode" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true, user_barcode: nil } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "not covid trained" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: true, user_barcode: '111222', covid_trained?: false } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "does not circulate" do
      let(:stubbed_questions) { { etas?: false, item_data?: false, circulates?: false, user_barcode: '111222', covid_trained?: false } }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end
  end

  describe "#request?" do
    let(:stubbed_questions) { { user_barcode: nil } }
    it 'can not be requested' do
      expect(decorator.request?).to be_falsey
    end

    context "with a user barcode and not covid trained" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: false } }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "with a user barcode and covid trained and any service" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf'] } }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "with a user barcode and covid trained and no services" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: [] } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and ill_eligible" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and borrow_direct" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and aeon?" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and traceable" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: false, traceable?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and in_process?" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: false, in_process?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "with a user barcode and covid trained and on_order?" do
      let(:stubbed_questions) { { user_barcode: "1234", covid_trained?: true, on_order?: true } }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end
  end

  describe "#will_submit_via_form?" do
    let(:stubbed_questions) { { item_data?: true, services: ["on_shelf"], recap_edd?: false, recap?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false } }
    it 'will not be submitted' do
      expect(decorator.will_submit_via_form?).to be_falsey
    end

    context "item data and on_shelf" do
      let(:stubbed_questions) { { item_data?: true, services: ["on_shelf"], recap_edd?: false, recap?: false, circulates?: true, on_shelf?: true, in_library_use_only?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "item data and at recap" do
      let(:stubbed_questions) { { item_data?: true, services: ["recap"], recap_edd?: false, recap?: true, circulates?: true, on_shelf?: false, in_library_use_only?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "item data and at recap and edd eligible" do
      let(:stubbed_questions) { { item_data?: true, services: ["recap", "recap_edd"], recap_edd?: true, recap?: true, circulates?: true, on_shelf?: false, in_library_use_only?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "item data and at recap only edd eligible" do
      let(:stubbed_questions) { { item_data?: true, services: ["recap_edd"], recap_edd?: true, recap?: false, circulates?: true, on_shelf?: false, in_library_use_only?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data, but circulates" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, recap_edd?: true, recap?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data, but circulates and etas" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, recap_edd?: true, recap?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data, but circulates and etas and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '1122333', recap_edd?: true, recap?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data, but circulates and etas and traceable no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil, recap_edd?: true, recap?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data, but circulates and etas and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '1122333', recap_edd?: true, recap?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data, but circulates and etas and in_process no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil, recap_edd?: true, recap?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data, but circulates and etas and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '11222333', recap_edd?: true, recap?: false } }
      it 'will be submitted' do
        pending "ReCAP is closed for maintenance"
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data, but circulates and etas and on_order no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: true, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil, recap_edd?: true, recap?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and scsb_in_library_use" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: true } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and on order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and on order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and on order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and ill_eligible and on order and no user bar code" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and scsb_in_library_use" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: true } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup?" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '11122233' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable and no user barcode " do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: '111222333' } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: '111222333' } }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, user_barcode: nil } }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and scsb_in_library_use?" do
      let(:stubbed_questions) { { item_data?: false, circulates?: false, services: ["on_shelf"], recap?: false, recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: true } }
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
      let(:stubbed_questions) { { on_order?: false, in_process?: false, traceable?: false, aeon?: true } }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
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

    context "an item that does not circulate and not recap and not charged and not aeon and campus authorized" do
      let(:stubbed_questions) { { etas?: false, circulates?: false, recap?: false, charged?: false, aeon?: false, campus_authorized: true, location: { 'library' => { 'code' => 'firestone' } } } }
      it "returns a url" do
        expect(decorator.libcal_url).to eq("https://libcal.princeton.edu/seats?lid=1919")
      end
    end
  end
end
