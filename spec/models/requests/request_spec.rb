require 'spec_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :new_episodes } do
  context "with a bad system_id" do
    let(:user) { FactoryGirl.build(:user) }
    let(:bad_system_id) { 'foo' }
    let(:params) do
      {
        system_id: bad_system_id,
        user: user
      }
    end
    let(:bad_request) { described_class.new(params) }
    describe '#solr_doc' do
      it 'returns an empty document response without a valid system id' do
        expect(bad_request.solr_doc(bad_system_id).empty?).to be true
      end
    end
  end

  context "with a system_id and a mfhd that has a holding record with an attached item record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:bad_system_id) { 'foo' }
    let(:params) do
      {
        system_id: '8880549',
        mfhd: '8805567',
        user: user
      }
    end
    let(:request_with_holding_item) { described_class.new(params) }

    describe "#doc" do
      it "returns a solr document" do
        expect(request_with_holding_item.doc).to be_truthy
      end
    end

    describe '#solr_doc' do
      it 'returns hash with a valid system id' do
        expect(request_with_holding_item.solr_doc(request_with_holding_item.system_id)).to be_a(Hash)
      end
    end

    describe "#display_metadata" do
      it "returns a display title" do
        expect(request_with_holding_item.display_metadata[:title]).to be_truthy
      end

      it "returns a author display" do
        expect(request_with_holding_item.display_metadata[:author]).to be_truthy
      end
    end

    describe "#language" do
      it "returns a language_code" do
        expect(request_with_holding_item.language).to be_truthy
      end

      it "returns a language IANA code" do
        expect(request_with_holding_item.language).to eq 'en'
      end

      # Doesn't do this yet
      # it "returns two-character ISO 639-1 language code" do
      #   expect(request_with_holding_item.display_metadata[:author]).to be_truthy
      # end
    end

    describe "#ctx" do
      it "produces an ILLiad flavored openurl" do
        expect(request_with_holding_item.ctx).to be_an_instance_of(OpenURL::ContextObject)
      end
    end

    describe '#openurl_ctx_kev' do
      it 'returns an encoded query string' do
        expect(request_with_holding_item.openurl_ctx_kev).to be_a(String)
        request_with_holding_item.ctx.referent.identifiers.each do |identifier|
          expect(request_with_holding_item.openurl_ctx_kev).to include(CGI.escape(identifier))
        end
      end
    end

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(request_with_holding_item.requestable).to be_truthy
        expect(request_with_holding_item.requestable.size).to eq(1)
        expect(request_with_holding_item.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "Contains a requestable object with a holding" do
        expect(request_with_holding_item.requestable[0].holding).to be_truthy
      end

      it "Contains a requestable object with an item" do
        expect(request_with_holding_item.requestable[0].item?).to be_truthy
      end

      it "has a mfhd" do
        expect(request_with_holding_item.requestable[0].holding).to be_truthy
        expect(request_with_holding_item.requestable[0].holding.key?("8805567")).to be_truthy
      end

      it "has location data" do
        expect(request_with_holding_item.requestable[0].location).to be_truthy
      end
    end

    describe "#load_locations" do
      it "provides a list of location data" do
        expect(request_with_holding_item.locations.size).to eq(1)
        expect(request_with_holding_item.locations.key?('ues')).to be_truthy
      end
    end

    describe "#system_id" do
      it "has a system id" do
        expect(request_with_holding_item.system_id).to be_truthy
        expect(request_with_holding_item.system_id).to eq('8880549')
      end
    end

    describe '#user' do
      it 'returns a user object' do
        expect(request_with_holding_item.user.is_a?(User)).to be true
      end
    end

    describe "#thesis?" do
      it "does not identify itself as a thesis request" do
        expect(request_with_holding_item.thesis?).to be_falsy
      end
    end

    describe "#numismatics?" do
      it "does not identify itself as a numismatics request" do
        expect(request_with_holding_item.numismatics?).to be_falsy
      end
    end
  end

  context "with a system_id and a mfhd that only has a holding record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '1791763',
        mfhd: '2056183',
        user: user
      }
    end
    let(:request_with_only_holding) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_holding.requestable).to be_truthy
        expect(request_with_only_holding.requestable.size).to eq(1)
        expect(request_with_only_holding.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a mfhd" do
        expect(request_with_only_holding.requestable[0].holding).to be_truthy
        expect(request_with_only_holding.requestable[0].holding.key?("2056183")).to be_truthy
      end

      it "has location data" do
        expect(request_with_only_holding.requestable[0].location).to be_truthy
      end
    end
  end

  context "with a system_id only that has holdings and item records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '490930',
        user: user
      }
    end

    let(:request_system_id_only_with_holdings_items) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings_items.requestable).to be_truthy
        expect(request_system_id_only_with_holdings_items.requestable.size).to eq(98)
        expect(request_system_id_only_with_holdings_items.any_pageable?).to be(false)
        expect(request_system_id_only_with_holdings_items.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings_items.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings_items.holdings.size).to eq(2)
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(request_system_id_only_with_holdings_items.sorted_requestable.size).to eq(2)
      end

      it "assigns items to the correct mfhd" do
        request_system_id_only_with_holdings_items.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end
  end

  context "with a system_id that only has holdings records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '4758976',
        user: user
      }
    end
    let(:request_system_id_only_with_holdings) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings.requestable).to be_truthy
        expect(request_system_id_only_with_holdings.requestable.size).to eq(1)
        expect(request_system_id_only_with_holdings.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings.holdings.size).to eq(1)
      end
    end
  end

  context "with a system_id that has holdings records that do and don't have item records attached" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2478499',
        user: user
      }
    end
    let(:request_system_id_only_with_holdings_with_some_items) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings_with_some_items.requestable).to be_truthy
        expect(request_system_id_only_with_holdings_with_some_items.requestable.size).to eq(9)
        expect(request_system_id_only_with_holdings_with_some_items.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings_with_some_items.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings_with_some_items.holdings.size).to eq(9)
      end
    end
  end

  context "A system id that has a holding with item on reserve" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '8179402',
        user: user
      }
    end
    let(:request_with_items_on_reserve) { described_class.new(params) }

    describe "#requestable" do
      it "is on reserve" do
        expect(request_with_items_on_reserve.requestable.first.on_reserve?).to be_truthy
      end
    end
  end

  context "A system id that has a holding with items in a temporary location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '6195942',
        user: user
      }
    end
    let(:request_with_items_at_temp_locations) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(request_with_items_at_temp_locations.requestable).to be_truthy
        expect(request_with_items_at_temp_locations.requestable.size).to eq(7)
        expect(request_with_items_at_temp_locations.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data that reflects an item's temporary location" do
        expect(request_with_items_at_temp_locations.requestable.first.location["code"]).to eq('sciresp')
      end

      it "locations data that uses a permenant location when no temporary code is specified" do
        expect(request_with_items_at_temp_locations.requestable.last.location["code"]).to eq('sci')
      end
    end
  end

  context "a system_id with no holdings or items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2385868',
        user: user
      }
    end
    let(:request_with_only_system_id) { described_class.new(params) }

    describe "#requestable" do
      it "does not have a list of request objects" do
        expect(request_with_only_system_id.requestable.empty?).to be true
      end
    end
  end

  context "when a recap with no items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '4759591',
        mfhd: '4978217',
        user: user
      }
    end
    let(:request_with_only_system_id) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end
    end

    describe "#thesis?" do
      it "identifies itself as a thesis request" do
        expect(request_with_only_system_id.thesis?).to be_falsey
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(request_with_only_system_id.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        request_with_only_system_id.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end
  end

  context "When passed a system_id for a theses record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: 'dsp01rr1720547',
        mfhd: 'thesis',
        user: user
      }
    end
    let(:request_with_only_system_id) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a thesis holding location" do
        expect(request_with_only_system_id.requestable[0].holding.key?('thesis')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location['code']).to eq 'mudd'
        expect(request_with_only_system_id.requestable[0].voyager_managed?).to be_falsey
      end
    end

    describe "#thesis?" do
      it "identifies itself as a thesis request" do
        expect(request_with_only_system_id.thesis?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(request_with_only_system_id.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        request_with_only_system_id.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('MUDD')
      end

      it 'shouuld have an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'shouuld have an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to thesis' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('thesis')
      end
    end
  end

  context "When passed a system_id for a numismatics record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: 'coin-1167/',
        mfhd: 'numismatics',
        user: user
      }
    end
    let(:request_with_only_system_id) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a numismatics holding location" do
        expect(request_with_only_system_id.requestable[0].holding.key?('numismatics')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location['code']).to eq 'num'
        expect(request_with_only_system_id.requestable[0].voyager_managed?).to be_falsey
      end
    end

    describe "#numismatics?" do
      it "identifies itself as a numismatics request" do
        expect(request_with_only_system_id.numismatics?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(request_with_only_system_id.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        request_with_only_system_id.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it 'has an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'has an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to numismatics' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('numismatics')
      end
    end
  end

  context "When passed a system_id for a numismatics record without a mfhd" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: 'coin-1167',
        user: user
      }
    end
    let(:request_with_only_system_id) { described_class.new(params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a thesis holding location" do
        expect(request_with_only_system_id.requestable[0].holding.key?('numismatics')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location['code']).to eq 'num'
        expect(request_with_only_system_id.requestable[0].voyager_managed?).to be_falsey
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(request_with_only_system_id.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        request_with_only_system_id.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it 'has an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'shouuld have an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to numismatics' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('numismatics')
      end
    end
  end

  context "When passed an ID for a paging location in nec outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2937003',
        user: user
      }
    end
    let(:request_at_paging_outside) { described_class.new(params) }

    describe "#requestable" do
      it "is unavailable" do
        expect(request_at_paging_outside.requestable[0].location['code']).to eq('nec')
        expect(request_at_paging_outside.any_pageable?).to be(false)
        expect(request_at_paging_outside.requestable[0].pageable?).to be_nil
      end
    end
  end

  # context "When passed an ID for a paging location in nec  within a paging call number range" do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '2942771',
  #       user: user
  #     }
  #   }
  #   let(:request_at_paging_nec_multiple) { described_class.new(params) }
  #

  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_nec_multiple.requestable[0].location['code']).to eq('nec')
  #       expect(request_at_paging_nec_multiple.requestable[0].pageable?).to eq(true)
  #     end
  #   end

  #   describe "#any_pageable?" do
  #     it "should return true when all requestable items are pageable?" do
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_truthy
  #     end

  #     it "should return true when only some of the requestable items are pageable?" do
  #       request_at_paging_nec_multiple.requestable.first.item["status"] = 'Charged'
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_truthy
  #     end

  #     it "should return false when all requestable items are not pageable?" do
  #       request_at_paging_nec_multiple.requestable.each do |requestable|
  #         requestable.item["status"] = 'Charged'
  #         requestable.services = []
  #       end
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_falsy
  #     end
  #   end
  # end

  context "When passed an ID for a paging location in f outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '4340413',
        user: user
      }
    end
    let(:request_at_paging_f) { described_class.new(params) }

    describe "#pageable?" do
      it "is be false" do
        expect(request_at_paging_f.requestable[0].location['code']).to eq('f')
        expect(request_at_paging_f.requestable[0].pageable?).to be_nil
      end
    end
  end
  # 6009363 returned
  # context "When passed an ID for a paging location f within a call in a range" do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '6009363',
  #       user: user
  #     }
  #   }
  #   let(:request_at_paging_f) { described_class.new(params) }
  #
  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_f.any_pageable?).to be(true)
  #       expect(request_at_paging_f.requestable[0].location['code']).to eq('f')
  #       expect(request_at_paging_f.requestable[0].pageable?).to eq(true)
  #       expect(request_at_paging_f.requestable[0].pickup_locations.size).to eq(1)
  #     end
  #   end
  # end

  # from the A range in "f"
  context "When passed an ID for a paging location f outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9545726',
        user: user
      }
    end
    let(:request_at_paging_f) { described_class.new(params) }

    describe "#requestable" do
      it "is unavailable" do
        expect(request_at_paging_f.requestable[0].location['code']).to eq('f')
        expect(request_at_paging_f.requestable[0].pageable?).to eq(nil)
        expect(request_at_paging_f.any_pageable?).to be(false)
        expect(request_at_paging_f.requestable[0].voyager_managed?).to eq(true)
      end
    end
  end

  # context "When passed an ID for an xl paging location" do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '9596359',
  #       user: user
  #     }
  #   }
  #   let(:request_at_paging_f) { described_class.new(params) }
  #
  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_f.requestable[0].location['code']).to eq('xl')
  #       expect(request_at_paging_f.requestable[0].pageable?).to eq(true)
  #       expect(request_at_paging_f.any_pageable?).to be(true)
  #       expect(request_at_paging_f.requestable[0].voyager_managed?).to eq(true)
  #     end
  #   end
  # end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9602549',
        user: user
      }
    end
    let(:request_with_on_order) { described_class.new(params) }
    let(:firestone_circ) do
      { label: "Firestone Library", gfa_pickup: "PA", staff_only: false }
    end
    let(:architecture) do
      { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }
    end

    describe "#requestable" do
      it "has requestable items" do
        expect(request_with_on_order.requestable.size).to be >= 1
      end

      it "has a requestable with 'on order' service" do
        expect(request_with_on_order.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "has a requestable on order item" do
        expect(request_with_on_order.requestable[0].voyager_managed?).to eq(true)
      end

      it "provides a list of the default pickup locations" do
        expect(request_with_on_order.default_pickups).to be_truthy
        expect(request_with_on_order.default_pickups).to be_an(Array)
        # test that it is an array of hashes
        expect(request_with_on_order.default_pickups.size).to be > 1
        expect(request_with_on_order.default_pickups.include?(firestone_circ)).to be_truthy
      end

      it "lists Firestone as the first choice" do
        expect(request_with_on_order.default_pickups.first).to eq(firestone_circ)
      end

      it "alphas sort the pickups between Firestone and staff locations" do
        expect(request_with_on_order.default_pickups[1]).to eq(architecture)
      end
    end
  end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9602551',
        mfhd: '9442918',
        user: user
      }
    end
    let(:request_with_on_order) { described_class.new(params) }

    describe "#requestable" do
      it "has requestable items" do
        expect(request_with_on_order.requestable.size).to be >= 1
      end

      it "has a requestable with 'on order' service" do
        expect(request_with_on_order.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "has a requestable on order item" do
        expect(request_with_on_order.requestable[0].voyager_managed?).to eq(true)
      end
    end
  end

  # Oversize ID pageable
  # context "When passed an ID for an Item with that is Oversize" do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '3785401',
  #       user: user
  #     }
  #   }
  #   let(:request_oversize) { described_class.new(params) }
  #

  #   describe "#requestable" do
  #     it "should have an requestable items" do
  #       expect(request_oversize.requestable.size).to be >= 1
  #     end

  #     it "should be in a location that contains some pageable items" do
  #       expect(request_oversize.requestable[0].location['code']).to eq('f')
  #       expect(request_oversize.requestable[0].voyager_managed?).to eq(true)
  #     end

  #     it "should be have pageable items" do
  #       expect(request_oversize.any_pageable?).to be(true)
  #     end

  #     it "should have a pageable item" do
  #       expect(request_oversize.requestable[0].pageable?).to eq(true)
  #     end
  #   end
  # end

  # Item with no call number 9602545
  context "When passed an ID for an Item in a pageable location that has no call number" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9602545',
        user: user
      }
    end
    let(:request_no_callnum) { described_class.new(params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request_no_callnum.requestable.size).to be >= 1
      end

      it "is in a pageable location" do
        expect(request_no_callnum.requestable[0].location['code']).to eq('f')
        expect(request_no_callnum.requestable[0].voyager_managed?).to eq(true)
      end

      it "does not have any pageable items" do
        expect(request_no_callnum.any_pageable?).to be(false)
      end

      it "has a pageable item" do
        expect(request_no_callnum.requestable[0].pageable?).to be_nil
      end
    end
  end
  ## Add context for Visuals when available
  ## Add context for EAD when available
  # http://localhost:4000/requests/2002206?mfhd=2281830
  context "When passed a mfhd with missing items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2002206',
        mfhd: '2281830',
        user: user
      }
    end
    let(:request_with_missing) { described_class.new(params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request_with_missing.requestable.size).to be >= 1
      end

      # TODO: Remove when campus has re-opened
      it "does not show missing items as eligible for ill" do
        expect(request_with_missing.requestable[2].services.include?('ill')).to be_falsey
      end

      # TODO: Activate test when campus has re-opened
      xit "should show missing items as eligible for ill" do
        expect(request_with_missing.requestable[2].services.include?('ill')).to be_truthy
      end

      it "is enumerated" do
        expect(request_with_missing.requestable[2].enumerated?).to be true
      end
    end
  end

  context "When passed an Aeon ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9627261',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "shows item as aeon eligble" do
        expect(request.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "Aeon item with holdings without items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '616086',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#requestable" do
      it "has a requestable items" do
        expect(request.requestable.length).to eq(10)
      end

      it "does not have any item data" do
        expect(request.requestable.first.item).to be_nil
      end

      it "is eligible for aeon services" do
        expect(request.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9676483',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      # TODO: Remove when campus has re-opened
      # it "is not eligible for recap services during campus closure" do
      #   expect(request.requestable.last.services.include?('recap')).to be_true
      # end

      # TODO: Activate test when campus has re-opened
      # it "is eligible for recap services with circulating items" do
      #   expect(request.requestable.first.services.include?('recap')).to be_truthy
      #   expect(request.requestable.first.scsb_in_library_use?).to be_falsey
      # end

      it "is eligible for recap_edd services" do
        expect(request.requestable.first.services.include?('recap_edd')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID and mfhd for a serial at a non EDD location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '426420',
        mfhd: '464640',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for recap services during campus closure" do
        expect(request.requestable.last.services.include?('recap')).to be_falsy
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for recap services" do
        expect(request.requestable.last.services.include?('recap')).to be_truthy
      end

      it "is eligible for recap_edd services" do
        expect(request.requestable.last.services.include?('recap_edd')).to be_falsy
      end
    end

    describe '#serial?' do
      it 'returns true when the item is a serial' do
        expect(request.serial?).to be true
      end
    end
  end

  context "When passed an unavailable item where other local copies are on reserve." do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9168829',
        mfhd: '9048082',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#borrow_direct_eligible?" do
      # TODO: Remove when campus has re-opened
      it "is not Borrow Direct Eligible" do
        expect(request.borrow_direct_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "Should be Borrow Direct Eligible" do
        expect(request.borrow_direct_eligible?).to be true
      end
    end
  end

  context "When passed a Recallable Item that is eligible for Borrow Direct" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9738136',
        mfhd: '9558038',
        user: user
      }
    end
    let(:request) { described_class.new(params) }

    describe "#borrow_direct_eligible?" do
      # TODO: Remove when campus has re-opened
      it "is not Borrow Direct Eligible" do
        expect(request.borrow_direct_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "Should be Borrow Direct Eligible" do
        expect(request.borrow_direct_eligible?).to be true
      end
    end

    describe "#ill_eligible?" do
      # TODO: Remove when campus has re-opened
      it 'is not ILL Eligible' do
        expect(request.ill_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit 'Should be ILL Eligible' do
        expect(request.ill_eligible?).to be true
      end
    end

    describe "#isbn_numbers?" do
      it 'returns true if a request has an isbn' do
        expect(request.isbn_numbers?).to be true
      end
    end

    describe "#isbn_numbers" do
      it 'returns an array of all attached isbn numbers' do
        expect(request.isbn_numbers.is_a?(Array)).to be true
        expect(request.isbn_numbers.size).to eq(1)
      end
    end

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for recap services" do
        expect(request.requestable.first.services.size).to eq(0)
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for recap services" do
        expect(request.requestable.first.services.size).to eq(3)
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for ill services" do
        expect(request.requestable.first.services.include?('ill')).to be_falsey
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for ill services" do
        expect(request.requestable.first.services.include?('ill')).to be_truthy
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for borrow direct services" do
        expect(request.requestable.first.services.include?('bd')).to be_falsey
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for borrow direct services" do
        expect(request.requestable.first.services.include?('bd')).to be_truthy
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for recall" do
        expect(request.requestable.first.services.include?('recall')).to be_falsey
        expect(request.requestable.first.ill_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for recall" do
        expect(request.requestable.first.services.include?('recall')).to be_truthy
        expect(request.requestable.first.ill_eligible?).to be true
      end
    end
  end

  context 'When passed an item that is traceable and mappable' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9907433',
        mfhd: '9723988',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "is on the shelf" do
        expect(request.requestable.first.services.include?('on_shelf')).to be_truthy
      end

      # these tests are temporarily pending until trace feature is resolved
      # see https://github.com/pulibrary/requests/issues/164 for info

      xit "should be eligible for multiple services" do
        expect(request.requestable.first.services.size).to eq(2)
      end

      xit "should be eligible for trace services" do
        expect(request.requestable.first.services.include?('trace')).to be_truthy
        expect(request.requestable.first.traceable?).to be true
      end
    end
  end
  # 495501
  context 'When passed a holding with a null item record' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '495501',
        mfhd: '538750',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  # 9994692
  context 'When passed a holding with all online items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9994692',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#requestable' do
      it "is all online" do
        expect(request.all_items_online?).to be true
      end
    end
  end

  # 9746776
  context 'When passed a holdings with mixed physical and online items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9746776',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#requestable' do
      it "is all online" do
        expect(request.all_items_online?).to be false
      end
    end
  end

  # 4815239
  context 'When passed a non-enumerated holdings with at least one loanable item' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '4815239',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        pending "Lewis library closed"
        expect(request.any_loanable_copies?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'is not borrow_direct_eligible' do
        expect(request.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Enumerated record with charged items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '495220',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'is not borrow_direct_eligible' do
        expect(request.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Enumerated record without charged items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '7494358',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end

    describe '#any_enumerated?' do
      it 'is enumerated' do
        expect(request.any_enumerated?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'is not borrow_direct_eligible' do
        expect(request.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Multi-holding record with charged items and items available at non-restricted locations' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '5596067',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'is not borrow_direct_eligible' do
        expect(request.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Multi-holding record with charged items and items available at restricted locations' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9696811',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be false
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'is not borrow_direct_eligible' do
        expect(request.borrow_direct_eligible?).to be false
      end
    end
  end

  ### Review this test
  context 'RBSC Items and Borrow Direct' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2631265',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#borrow_direct_eligible?' do
      # TODO: Remove when campus has re-opened
      it 'is not borrow_direct_eligible?' do
        expect(request.borrow_direct_eligible?).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit 'should be borrow_direct_eligible?' do
        expect(request.borrow_direct_eligible?).to be true
      end
    end

    describe '#isbn_numbers?' do
      it 'returns false when there are no isbns present' do
        expect(request.isbn_numbers?).to be false
      end
    end
  end

  context 'When a barcode only user visits the site' do
    let(:user) { FactoryGirl.build(:valid_barcode_patron) }
    let(:params) do
      {
        system_id: '495501',
        mfhd: '538750',
        user: user
      }
    end
    let(:request) { described_class.new(params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  context "When passed mfhd and source params" do
    let(:user) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) do
      {
        system_id: '1969881',
        mfhd: '2246633',
        source: 'pulsearch',
        user: user
      }
    end
    let(:request_with_optional_params) { described_class.new(params) }

    describe "#request" do
      it "has accessible mfhd param" do
        expect(request_with_optional_params.mfhd).to eq('2246633')
      end

      it "has accessible source param" do
        expect(request_with_optional_params.source).to eq('pulsearch')
      end
    end
  end

  context "When passed an ID for a preservation office location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9712355',
        user: user
      }
    end
    let(:request_for_preservation) { described_class.new(params) }
    describe "#requestable" do
      it "has a preservation location code" do
        expect(request_for_preservation.requestable[0].location['code']).to eq('pres')
      end
    end
  end

  context 'A borrow Direct item that is not available' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '9907486',
        user: user
      }
    end
    let(:request_with_title_author) { described_class.new(params) }

    describe '#fallback_query_params' do
      it 'has a title and author parameters when both are present' do
        expect(request_with_title_author.fallback_query_params.key?(:title)).to be true
        expect(request_with_title_author.fallback_query_params.key?(:author)).to be true
      end
    end

    describe '#fallback_query' do
      it 'returns a borrow direct fallback query url' do
        expect(request_with_title_author.fallback_query).to be_truthy
        expect(request_with_title_author.fallback_query).to include(::BorrowDirect::Defaults.html_base_url)
        expect(request_with_title_author.fallback_query).to include('a+history+of+the+modern+middle+east')
      end
    end
  end

  context "When passed a system_id for a record with a single aeon holding" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '4693146',
        user: user
      }
    end
    let(:request_with_single_aeon_holding) { described_class.new(params) }

    describe "#requestable" do
      describe "#single_aeon_requestable?" do
        it "identifies itself as a single aeon requestable" do
          expect(request_with_single_aeon_holding.single_aeon_requestable?).to be_truthy
        end
      end
    end
  end

  context "When passed a system_id for a record with a mixed holding, one of which has no item data and is at an annex." do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '2286894',
        user: user
      }
    end
    let(:request_with_fill_in_eligible_holding) { described_class.new(params) }

    describe "#requestable" do
      describe "#fill_in_eligible" do
        it "identifies any mfhds that require fill in option" do
          expect(request_with_fill_in_eligible_holding.fill_in_eligible("2576882")).to be_truthy
        end
      end
    end
  end

  # This is an error condition
  # context "When passed a system_id for a record that has no item data and is not at an annex." do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '10139326',
  #       user: user
  #     }
  #   }
  #   let(:request_with_fill_in_eligible_holding) { described_class.new(params) }
  #
  #
  #   describe "#requestable" do
  #     describe "#fill_in_eligible" do
  #       it "should identify any mfhds that require fill in option" do
  #         expect(request_with_fill_in_eligible_holding.fill_in_eligible "9929080").to be_truthy
  #       end
  #     end
  #   end
  # end

  context "When passed a system_id for a record with enumerable items at annex" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '3845517',
        user: user
      }
    end
    let(:request_with_fill_in_eligible_holding) { described_class.new(params) }

    describe "#requestable" do
      describe "#fill_in_eligible" do
        it "identifies any mfhds that require fill in option" do
          expect(request_with_fill_in_eligible_holding.fill_in_eligible("4148813")).to be_truthy
        end
      end
    end
  end

  context "A SCSB id with a single holding" do
    let(:user) { FactoryGirl.build(:user) }
    let(:scsb_single_holding_item) { fixture('/SCSB-5290772.json') }
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-5290772',
        user: user,
        source: 'pulsearch'
      }
    end
    let(:scsb_availability_params) do
      {
        bibliographicId: "12134967",
        institutionId: "CUL"
      }
    end
    let(:scsb_availability_response) { fixture('/scsb_single_avail.json') }
    let(:request_scsb) { described_class.new(params) }
    before do
      stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{params[:system_id]}.json")
        .to_return(status: 200, body: scsb_single_holding_item, headers: {})
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
        .to_return(status: 200, body: scsb_availability_response)
    end
    describe '#requestable' do
      it 'has one requestable item' do
        expect(request_scsb.requestable.size).to eq(1)
      end
    end
    describe '#other_id' do
      it 'provides an other id value' do
        expect(request_scsb.other_id).to eq('5992543')
      end
    end
    describe '#scsb_owning_institution' do
      it 'provides the SCSB owning institution ID' do
        expect(request_scsb.scsb_owning_institution(location_code)).to eq('CUL')
      end
    end
    describe '#recap_edd?' do
      it 'is request via EDD' do
        expect(request_scsb.requestable.first.recap_edd?).to be true
      end
    end
  end

  context "A SCSB id that does not allow edd" do
    let(:user) { FactoryGirl.build(:user) }
    let(:scsb_edd_item) { fixture('/SCSB-5640725.json') }
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-5640725',
        user: user,
        source: 'pulsearch'
      }
    end
    let(:scsb_availability_params) do
      {
        bibliographicId: "9488888",
        institutionId: "CUL"
      }
    end
    let(:scsb_availability_response) { fixture('/scsb_single_avail.json') }
    let(:request_scsb) { described_class.new(params) }
    before do
      stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{params[:system_id]}.json")
        .to_return(status: 200, body: scsb_edd_item, headers: {})
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
        .to_return(status: 200, body: scsb_availability_response)
    end
    describe '#requestable' do
      it 'has one requestable item' do
        expect(request_scsb.requestable.size).to eq(1)
      end
    end
    describe '#recap_edd?' do
      it 'is requestable via EDD' do
        expect(request_scsb.requestable.first.recap_edd?).to be false
      end
    end
  end

  context "A SCSB with an unknown format" do
    let(:user) { FactoryGirl.build(:user) }
    let(:scsb_no_format) { fixture('/SCSB-7935196.json') }
    let(:location_code) { 'scsbnypl' }
    let(:params) do
      {
        system_id: 'SCSB-7935196',
        user: user,
        source: 'pulsearch'
      }
    end
    let(:scsb_availability_params) do
      {
        bibliographicId: ".b106574619",
        institutionId: "NYPL"
      }
    end
    let(:scsb_availability_response) { fixture('/scsb_single_avail.json') }
    let(:request_scsb) { described_class.new(params) }
    before do
      stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{params[:system_id]}.json")
        .to_return(status: 200, body: scsb_no_format, headers: {})
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
        .to_return(status: 200, body: scsb_availability_response)
    end
    describe '#requestable' do
      it 'has an unknown format' do
        expect(request_scsb.ctx.referent.format).to eq('unknown')
      end
    end
  end
end
