require 'spec_helper'

describe Requests::Router, vcr: { cassette_name: 'requests_router', record: :new_episodes } do
  context "A Princeton Community User has signed in" do
    let(:user) { FactoryGirl.create(:user) }

    let(:scsb_single_holding_item) { fixture('/SCSB-2635660.json') }
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-2635660',
        user: user,
        source: 'CUL'
      }
    end
    let(:scsb_availability_params) do
      {
        bibliographicId: "667075",
        institutionId: "CUL"
      }
    end
    let(:scsb_availability_response) { '[{"itemBarcode":"CU53020880","itemAvailabilityStatus":"Not Available","errorMessage":null}]' }
    let(:request_scsb) { Requests::Request.new(params) }
    let(:requestable) { request_scsb.requestable.first }
    let(:router) { described_class.new(requestable: requestable, user: user) }

    describe "SCSB item that is charged" do
      before do
        stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{params[:system_id]}.json")
          .to_return(status: 200, body: scsb_single_holding_item, headers: {})
        stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
          .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
          .to_return(status: 200, body: scsb_availability_response)
      end

      # TODO: Remove when campus has re-opened
      it "does not have Borrow Direct, ILL, or Recall as a request service option" do
        expect(router.calculate_services.include?('bd')).to be_falsy
        expect(router.calculate_services.include?('ill')).to be_falsy
        expect(router.calculate_services.include?('recall')).to be_falsy
      end

      # TODO: Activate test when campus has re-opened
      xit "has Borrow Direct, ILL, but not Recall as a request service option" do
        expect(router.calculate_services.include?('bd')).to be_truthy
        expect(router.calculate_services.include?('ill')).to be_truthy
        expect(router.calculate_services.include?('recall')).to be_falsy
      end
    end

    describe "Online Holding" do
      let(:params) { {} }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:router) { described_class.new(requestable, user) }
      xit "Returns an Online Link" do
        expect(router.services.key?(:full_text)).to be_truthy
      end
    end

    describe "Print Holding in RBSC without items" do
      let(:params) { { system_id: 4, holding_id: 5, item_id: 6 } }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:router) { described_class.new(requestable, user) }
      xit "Returns an Aeon Reading Room Link" do
        expect(router.services.key?(:aeon)).to be_truthy
      end
    end

    describe "calculate_services" do
      let(:stubbed_questions) do
        { voyager_managed?: true, online?: false, in_process?: false,
          charged?: false, on_order?: false, aeon?: false,
          preservation?: false, annexa?: false, annexb?: false,
          plasma?: false, lewis?: false, recap?: false,
          item_data?: false, recap_edd?: false, pageable?: false, scsb_in_library_use?: false }
      end
      let(:requestable) { instance_double(Requests::Requestable, stubbed_questions) }

      context "online holding" do
        before do
          stubbed_questions[:online?] = true
        end
        it "returns online in the services" do
          expect(router.calculate_services).to eq(['online'])
        end
      end

      context "in process" do
        before do
          stubbed_questions[:in_process?] = true
        end
        it "returns in_process in the services" do
          expect(router.calculate_services).to eq(['in_process'])
        end
        context "unauthorized user" do
          let(:user) { FactoryGirl.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
      end

      context "on order" do
        before do
          stubbed_questions[:on_order?] = true
        end
        it "returns on_order in the services" do
          expect(router.calculate_services).to eq(['on_order'])
        end
        context "unauthorized user" do
          let(:user) { FactoryGirl.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
      end

      context "aeon" do
        before do
          stubbed_questions[:aeon?] = true
        end
        it "returns aeon in the services" do
          expect(router.calculate_services).to eq(['aeon'])
        end
      end

      context "preservation" do
        before do
          stubbed_questions[:preservation?] = true
        end
        it "returns pres in the services" do
          expect(router.calculate_services).to eq(['pres'])
        end
      end

      context "annexa" do
        before do
          stubbed_questions[:annexa?] = true
        end
        it "returns annexa in the services" do
          expect(router.calculate_services).to eq(['annexa'])
        end
      end

      context "annexb" do
        before do
          stubbed_questions[:annexb?] = true
        end
        it "returns annexb in the services" do
          expect(router.calculate_services).to eq(['annexb'])
        end
      end

      context "plasma" do
        before do
          stubbed_questions[:plasma?] = true
        end
        it "returns ppl in the services" do
          expect(router.calculate_services).to eq(['ppl'])
        end
      end

      context "lewis" do
        before do
          stubbed_questions[:lewis?] = true
        end
        it "returns lewis in the services" do
          expect(router.calculate_services).to eq(['lewis'])
        end
      end

      context "recap" do
        before do
          stubbed_questions[:recap?] = true
          stubbed_questions[:item_data?] = true
          stubbed_questions[:recap_edd?] = true
          stubbed_questions[:ask_me?] = true
        end
        it "returns recap_edd in the services" do
          expect(router.calculate_services).to eq(['recap_edd'])
        end
        context "unauthorized user" do
          let(:user) { FactoryGirl.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
        context "no items" do
          before do
            stubbed_questions[:item_data?] = false
          end
          it "returns recap_no_items in the services" do
            expect(router.calculate_services).to eq(['recap_no_items'])
          end
        end
      end

      context "pageable" do
        before do
          stubbed_questions[:pageable?] = true
        end
        it "returns paging in the services" do
          expect(router.calculate_services).to eq(['paging'])
        end
      end

      context "on_shelf" do
        it "returns on_shelf in the services" do
          expect(router.calculate_services).to eq(['on_shelf'])
        end
      end

      context "not voyager managed or scsb" do
        before do
          stubbed_questions[:voyager_managed?] = false
          stubbed_questions[:scsb?] = false
        end
        it "returns aeon in the services" do
          expect(router.calculate_services).to eq(['aeon'])
        end
      end
    end

    describe "Print Holding in ReCAP with item record and open pickup locations" do
    end

    describe "Print Holding in ReCAP with item record and restricted pickup locations" do
    end

    describe "Print Holding at ReCAP with charged item" do
    end

    describe "Print Holding at ReCAP with EDD eligible item" do
    end

    describe "Annex Holding without item" do
    end

    describe "Annex Holding with item" do
      it "has pickup locations" do
      end
    end

    describe "Annex Holding with charged item" do
    end

    context "When an item is in a pageable location" do
      describe "It has a unavilable status" do
      end
    end

    context "When a firestone item" do
      describe "Open Holding with item" do
        xit "has a firestone locator link when a firestone item" do
          expect(router.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    context "When a non-frestone item" do
      describe "Open Holding with item" do
        xit "has a stackmap link when a firestone item" do
          expect(router.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    describe "Open Holding with charged item" do
    end

    describe "Open Holding without item" do
    end

    describe "Open Holding with Charged Item" do
    end

    describe "Thesis Collection Item" do
    end
  end

  # Fill in when we support guest authentication
  # context "An Access Patron has signed in" do
  #   let(:user) { FactoryGirl.create(:valid_access_patron) }

  #   describe "Print Holding with Charged Item"
  #   end
  # end

  # context "The user has not authenticated but can self-identify as an access patron" do
  #   let(:user) { FactoryGirl.create(:unauthenticated_patron) }

  #   describe "Print Holding with Charge Item" do
  #   end
  # end
end
