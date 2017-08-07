require 'spec_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :new_episodes } do
  context "with a bad system_id" do
    let(:user) { FactoryGirl.build(:user) }
    let(:bad_system_id) { 'foo' }
    let(:params) {
      {
        system_id: bad_system_id,
        user: user
      }
    }
    let(:bad_request) { described_class.new(params) }
    subject { bad_request }
    describe '#solr_doc' do
      it 'returns an empty document response without a valid system id' do
        expect(subject.solr_doc(bad_system_id).empty?).to be true
      end
    end
  end

  context "with a system_id and a mfhd that has a holding record with an attached item record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:bad_system_id) { 'foo' }
    let(:params) {
      {
        system_id: '8880549',
        mfhd: '8805567',
        user: user
      }
    }
    let(:request_with_holding_item) { described_class.new(params) }
    subject { request_with_holding_item }

    describe "#doc" do
      it "returns a solr document" do
        expect(subject.doc).to be_truthy
      end
    end

    describe '#solr_doc' do
      it 'returns hash with a valid system id' do
        expect(subject.solr_doc(subject.system_id)).to be_a(Hash)
      end
    end

    describe "#display_metadata" do
      it "returns a display title" do
        expect(subject.display_metadata[:title]).to be_truthy
      end

      it "returns a author display" do
        expect(subject.display_metadata[:author]).to be_truthy
      end
    end

    describe "#get_language" do
      it "returns a language_code" do
        expect(subject.get_language).to be_truthy
      end

      # Doesn't do this yet
      # it "returns two-character ISO 639-1 language code" do
      #   expect(subject.display_metadata[:author]).to be_truthy
      # end
    end

    describe "#ctx" do
      it "should produce an ILLiad flavored openurl" do
        expect(subject.ctx).to be_an_instance_of(OpenURL::ContextObject)
      end
    end

    describe '#openurl_ctx_kev' do
      it 'should return an encoded query string' do
        expect(subject.openurl_ctx_kev).to be_a(String)
        subject.ctx.referent.identifiers.each do |identifier|
          expect(subject.openurl_ctx_kev).to include(CGI.escape(identifier))
        end
      end
    end

    describe "#items?" do
      it "Has items" do
        expect(subject.items?).to be_truthy
      end
    end

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "Contains a requestable object with a holding" do
        expect(subject.requestable[0].holding).to be_truthy
      end

      it "Contains a requestable object with an item" do
        expect(subject.requestable[0].item?).to be_truthy
      end

      it "has a mfhd" do
        expect(subject.requestable[0].holding).to be_truthy
        expect(subject.requestable[0].holding.key? "8805567").to be_truthy
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end
    end

    describe "#load_locations" do
      it "provides a list of location data" do
        expect(subject.locations.size).to eq(1)
        expect(subject.locations.key? 'ues').to be_truthy
      end
    end

    describe "#system_id" do
      it "has a system id" do
        expect(subject.system_id).to be_truthy
        expect(subject.system_id).to eq('8880549')
      end
    end

    describe '#user' do
      it 'returns a user object' do
        expect(subject.user.is_a? User).to be true
      end
    end

    describe '#holdings?' do
      it 'returns holdings data' do
        expect(subject.holdings?).to be_truthy
      end
    end

    describe '#available?' do
      it 'returns a list of items' do
        expect(subject.available?).to be_truthy
      end
    end

    describe "#thesis?" do
      it "should not identify itself as a thesis request" do
        expect(subject.thesis?).to be_falsy
      end
    end
  end

  context "with a system_id and a mfhd that only has a holding record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '1791763',
        mfhd: '2056183',
        user: user
      }
    }
    let(:request_with_only_holding) { described_class.new(params) }
    subject { request_with_only_holding }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a mfhd" do
        expect(subject.requestable[0].holding).to be_truthy
        expect(subject.requestable[0].holding.key? "2056183").to be_truthy
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end
    end
  end

  context "with a system_id only that has holdings and item records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '490930',
        user: user
      }
    }

    let(:request_system_id_only_with_holdings_items) { described_class.new(params) }
    subject { request_system_id_only_with_holdings_items }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(98)
        expect(subject.has_pageable?).to be(false)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(2)
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(2)
      end

      it "assigns items to the correct mfhd" do
        subject.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end
  end

  context "with a system_id that only has holdings records" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4758976',
        user: user
      }
    }
    let(:request_system_id_only_with_holdings) { described_class.new(params) }
    subject { request_system_id_only_with_holdings }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(1)
      end
    end
  end

  context "with a system_id that has holdings records that do and don't have item records attached" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2478499',
        user: user
      }
    }
    let(:request_system_id_only_with_holdings_with_some_items) { described_class.new(params) }
    subject { request_system_id_only_with_holdings_with_some_items }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(9)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(subject.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(subject.holdings.size).to eq(9)
      end
    end
  end

  context "A system id that has a holding with item on reserve" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '8179402',
        user: user
      }
    }
    let(:request_with_items_on_reserve) { described_class.new(params) }
    subject { request_with_items_on_reserve }

    describe "#requestable" do
      it "should be on reserve" do
        expect(subject.requestable.first.on_reserve?).to be_truthy
      end
    end
  end

  context "A system id that has a holding with items in a temporary location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '6195942',
        user: user
      }
    }
    let(:request_with_items_at_temp_locations) { described_class.new(params) }
    subject { request_with_items_at_temp_locations }

    describe "#requestable" do
      it "should have a list of requestable objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(7)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "should have location data that reflects an item's temporary location" do
        expect(subject.requestable.first.location["code"]).to eq('sciresp')
      end

      it "should location data that uses a permenant location when no temporary code is specified" do
        expect(subject.requestable.last.location["code"]).to eq('sci')
      end
    end
  end

  context "a system_id with no holdings or items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2385868',
        user: user
      }
    }
    let(:request_with_only_system_id) { described_class.new(params) }
    subject { request_with_only_system_id }

    describe "#requestable" do
      it "should not have a list of request objects" do
        expect(subject.requestable.empty?).to be true
      end
    end
  end

  context "When passed a system_id for a theses record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: 'dsp01rr1720547',
        user: user
      }
    }
    let(:request_with_only_system_id) { described_class.new(params) }
    subject { request_with_only_system_id }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "should have a thesis holding location" do
        expect(subject.requestable[0].holding.key? 'thesis').to be_truthy
        expect(subject.requestable[0].location.key? 'code').to be_truthy
        expect(subject.requestable[0].location['code']).to eq ('mudd')
        expect(subject.requestable[0].voyager_managed?).to be_nil
      end
    end

    describe "#thesis?" do
      it "should identify itself as a thesis request" do
        expect(subject.thesis?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(1)
      end

      it "assigns items to the correct mfhd" do
        subject.sorted_requestable.each do |key, items|
          items.each do |item|
            expect(item.holding.keys.first).to eq(key)
          end
        end
      end
    end

    describe "#aeon_mapped_params" do
      it 'should include a Site param' do
        expect(subject.requestable[0].aeon_mapped_params.key? :Site).to be true
        expect(subject.requestable[0].aeon_mapped_params[:Site]).to eq('MUDD')
      end

      it 'shouuld have an Aeon Form Param' do
        expect(subject.requestable[0].aeon_mapped_params.key? :Form).to be true
        expect(subject.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'shouuld have an Aeon Action Param' do
        expect(subject.requestable[0].aeon_mapped_params.key? :Action).to be true
        expect(subject.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'should have a genre param set to thesis' do
        expect(subject.requestable[0].aeon_mapped_params.key? :genre).to be true
        expect(subject.requestable[0].aeon_mapped_params[:genre]).to eq('thesis')
      end
    end
  end

  context "When passed a system_id for a visuals record" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: 'visuals45246',
        user: user
      }
    }
    let(:request_with_only_system_id) { described_class.new(params) }
    subject { request_with_only_system_id }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "should not have a Voyager location" do
        expect(subject.requestable[0].holding.key? 'visuals').to be_truthy
        expect(subject.requestable[0].location.key? 'code').to be_truthy
        expect(subject.requestable[0].location['code']).to eq ('ga')
        expect(subject.requestable[0].voyager_managed?).to be_nil
      end
    end

    describe "#visuals?" do
      it "should identify itself as a visuals request" do
        expect(subject.visuals?).to be_truthy
      end
    end

    describe "#sorted_requestable" do
      it "returns a list of requestable objects grouped by mfhd" do
        expect(subject.sorted_requestable.size).to eq(1)
      end

      it "should not have any items attached" do
        expect(subject.items?).to be_nil
      end
    end

    describe "#aeon_mapped_params" do
      it 'should include a Site param' do
        expect(subject.requestable[0].aeon_mapped_params.key? :Site).to be true
        expect(subject.requestable[0].aeon_mapped_params[:Site]).to eq('RBSC')
      end
    end
  end

  # context "When passed an ID for a paging location within allowed call number range" do
  #   let(:user) { FactoryGirl.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '4472547',
  #       user: user
  #     }
  #   }
  #   let(:request_at_paging_charged) { described_class.new(params) }
  #   subject { request_at_paging_charged }
  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(subject.has_pageable?).to be(true)
  #       expect(subject.requestable[0].location['code']).to eq('nec')
  #       expect(subject.requestable[0].pageable?).to be_truthy
  #     end
  #   end
  # end

  context "When passed an ID for a paging location in nec outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2937003',
        user: user
      }
    }
    let(:request_at_paging_outside) { described_class.new(params) }
    subject { request_at_paging_outside }

    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('nec')
        expect(subject.has_pageable?).to be(false)
        expect(subject.requestable[0].pageable?).to be_nil
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
  #   subject { request_at_paging_nec_multiple }

  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(subject.requestable[0].location['code']).to eq('nec')
  #       expect(subject.requestable[0].pageable?).to eq(true)
  #     end
  #   end

  #   describe "#has_pageable?" do
  #     it "should return true when all requestable items are pageable?" do
  #       expect(subject.has_pageable?).to be_truthy
  #     end

  #     it "should return true when only some of the requestable items are pageable?" do
  #       subject.requestable.first.item["status"] = 'Charged'
  #       expect(subject.has_pageable?).to be_truthy
  #     end

  #     it "should return false when all requestable items are not pageable?" do
  #       subject.requestable.each do |requestable|
  #         requestable.item["status"] = 'Charged'
  #         requestable.services = []
  #       end
  #       expect(subject.has_pageable?).to be_falsy
  #     end
  #   end
  # end

  context "When passed an ID for a paging location in f outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4340413',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }

    describe "#pageable?" do
      it "should be be false" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to be_nil
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
  #   subject { request_at_paging_f }

  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(subject.has_pageable?).to be(true)
  #       expect(subject.requestable[0].location['code']).to eq('f')
  #       expect(subject.requestable[0].pageable?).to eq(true)
  #       expect(subject.requestable[0].pickup_locations.size).to eq(1)
  #     end
  #   end
  # end

  # from the A range in "f"
  context "When passed an ID for a paging location f outside of call number range" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9545726',
        user: user
      }
    }
    let(:request_at_paging_f) { described_class.new(params) }
    subject { request_at_paging_f }

    describe "#requestable" do
      it "should be unavailable" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].pageable?).to eq(nil)
        expect(subject.has_pageable?).to be(false)
        expect(subject.requestable[0].voyager_managed?).to eq(true)
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
  #   subject { request_at_paging_f }

  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(subject.requestable[0].location['code']).to eq('xl')
  #       expect(subject.requestable[0].pageable?).to eq(true)
  #       expect(subject.has_pageable?).to be(true)
  #       expect(subject.requestable[0].voyager_managed?).to eq(true)
  #     end
  #   end
  # end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602549',
        user: user
      }
    }
    let(:request_with_on_order) { described_class.new(params) }
    let(:firestone_circ) {
      { label: "Firestone Library", gfa_code: "PA" }
    }
    subject { request_with_on_order }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end

      it "should provide a list of the default pickup locations" do
        expect(subject.default_pickups).to be_truthy
        expect(subject.default_pickups).to be_an(Array)
        # test that it is an array of hashes
        expect(subject.default_pickups.size).to be > 1
        expect(subject.default_pickups.include?(firestone_circ)).to be_truthy
      end

      it "should list Firestone as the first choice" do
        expect(subject.default_pickups.first).to eq(firestone_circ)
      end
    end
  end

  context "When passed an ID for an On Order Title" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602551',
        mfhd: '9442918',
        user: user
      }
    }
    let(:request_with_on_order) { described_class.new(params) }
    subject { request_with_on_order }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].services.include?('on_order')).to be_truthy
      end

      it "should have a requestable on order item" do
        expect(subject.requestable[0].voyager_managed?).to eq(true)
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
  #   subject { request_oversize }

  #   describe "#requestable" do
  #     it "should have an requestable items" do
  #       expect(subject.requestable.size).to be >= 1
  #     end

  #     it "should be in a location that contains some pageable items" do
  #       expect(subject.requestable[0].location['code']).to eq('f')
  #       expect(subject.requestable[0].voyager_managed?).to eq(true)
  #     end

  #     it "should be have pageable items" do
  #       expect(subject.has_pageable?).to be(true)
  #     end

  #     it "should have a pageable item" do
  #       expect(subject.requestable[0].pageable?).to eq(true)
  #     end
  #   end
  # end

  # Item with no call number 9602545
  context "When passed an ID for an Item in a pageable location that has no call number" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9602545',
        user: user
      }
    }
    let(:request_no_callnum) { described_class.new(params) }
    subject { request_no_callnum }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be in a pageable location" do
        expect(subject.requestable[0].location['code']).to eq('f')
        expect(subject.requestable[0].voyager_managed?).to eq(true)
      end

      it "should not have any pageable items" do
        expect(subject.has_pageable?).to be(false)
      end

      it "should have a pageable item" do
        expect(subject.requestable[0].pageable?).to be_nil
      end
    end
  end
  ## Add context for Visuals when available
  ## Add context for EAD when available
  # http://localhost:4000/requests/2002206?mfhd=2281830
  context "When passed a mfhd with missing items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2002206',
        mfhd: '2281830',
        user: user
      }
    }
    let(:request_with_missing) { described_class.new(params) }
    subject { request_with_missing }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should show missing items as eligible for ill" do
        expect(subject.requestable[2].services.include?('ill')).to be_truthy
      end

      it "should be enumerated" do
        expect(subject.requestable[2].enumerated?).to be true
      end

      it "should provide an ILLiad URL" do
        expect(subject.requestable[2].illiad_request_url(subject.ctx, subject.requestable[2])).to start_with(Requests.config[:ill_base])
      end

      it "should provide illiad query parameters with enumeration" do
        enum = "Volume foo"
        expect(subject.requestable[2].illiad_query_parameters(subject.ctx, enum)).to include(CGI.escape(enum))
      end
    end
  end

  context "When passed an Aeon ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9627261',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should show item as aeon eligble" do
        expect(subject.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When passed an Aeon holding ID with no items" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '616086',
        mfhd: '5132984',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        # even though we are passing the mfhd, we are not limiting
        # it in the requestable so we can check all non-serials against BorrowDirect
        expect(subject.requestable.size).to eq(17)
      end

      it "should not have any item data" do
        expect(subject.requestable.first.item).to be_nil
      end

      it "should be eligible for aeon services" do
        expect(subject.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9676483',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.first.services.include?('recap')).to be_truthy
      end

      it "should be eligible for recap_edd services" do
        expect(subject.requestable.first.services.include?('recap_edd')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID and mfhd for a serial at a non EDD location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '426420',
        mfhd: '464640',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.last.services.include?('recap')).to be_truthy
      end

      it "should be eligible for recap_edd services" do
        expect(subject.requestable.last.services.include?('recap_edd')).to be_falsy
      end
    end

    describe '#serial?' do
      it 'returns true when the item is a serial' do
        expect(subject.serial?).to be true
      end
    end
  end

  context "When passed a Recallable Item that is eligible for Borrow Direct" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9738136',
        mfhd: '9558038',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }

    describe "#borrow_direct_eligible?" do
      it "Should be Borrow Direct Eligible" do
        expect(subject.borrow_direct_eligible?).to be true
      end
    end

    describe "#ill_eligible?" do
      it 'Should be ILL Eligible' do
        expect(subject.ill_eligible?).to be true
      end
    end

    describe "#isbn_numbers?" do
      it 'Should return true if a request has an isbn' do
        expect(subject.isbn_numbers?).to be true
      end
    end

    describe "#isbn_numbers" do
      it 'returns an array of all attached isbn numbers' do
        expect(subject.isbn_numbers.is_a?(Array)).to be true
        expect(subject.isbn_numbers.size).to eq(1)
      end
    end

    describe "#requestable" do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be eligible for recap services" do
        expect(subject.requestable.first.services.size).to eq(3)
      end

      it "should be eligible for ill services" do
        expect(subject.requestable.first.services.include?('ill')).to be_truthy
      end

      it "should be eligible for borrow direct services" do
        expect(subject.requestable.first.services.include?('bd')).to be_truthy
      end

      it "should be eligible for recall" do
        expect(subject.requestable.first.services.include?('recall')).to be_truthy
        expect(subject.requestable.first.ill_eligible?).to be true
      end
    end
  end

  context 'When passed an item that is traceable and mappable' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9907433',
        mfhd: '9723988',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end

      it "should be on the shelf" do
        expect(subject.requestable.first.services.include?('on_shelf')).to be_truthy
      end

      # these tests are temporarily pending until trace feature is resolved
      # see https://github.com/pulibrary/requests/issues/164 for info
      xit "should be eligible for multiple services" do
        expect(subject.requestable.first.services.size).to eq(2)
      end

      xit "should be eligible for trace services" do
        expect(subject.requestable.first.services.include?('trace')).to be_truthy
        expect(subject.requestable.first.traceable?).to be true
      end
    end
  end
  # 495501
  context 'When passed a holding with a null item record' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '495501',
        mfhd: '538750',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end
    end
  end

  # 9994692
  context 'When passed a holding with all online items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9994692',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should be all online" do
        expect(subject.all_items_online?).to be true
      end
    end
  end

  # 9746776
  context 'When passed a holdings with mixed physical and online items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9746776',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should be all online" do
        expect(subject.all_items_online?).to be false
      end
    end
  end

  # 4815239
  context 'When passed a non-enumerated holdings with at least one loanable item' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4815239',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#has_loanable_copy?' do
      it "should have available copy" do
        expect(subject.has_loanable_copy?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'should not be borrow_direct_eligible' do
        expect(subject.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Enumerated record with charged items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '495220',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#has_loanable_copy?' do
      it "should have available copy" do
        expect(subject.has_loanable_copy?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'should not be borrow_direct_eligible' do
        expect(subject.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Enumerated record without charged items' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '7494358',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#has_loanable_copy?' do
      it "should have available copy" do
        expect(subject.has_loanable_copy?).to be true
      end
    end

    describe '#has_enumerated?' do
      it 'should be enumerated' do
        expect(subject.has_enumerated?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'should not be borrow_direct_eligible' do
        expect(subject.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Multi-holding record with charged items and items available at non-restricted locations' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '5596067',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#has_loanable_copy?' do
      it "should have available copy" do
        expect(subject.has_loanable_copy?).to be true
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'should not be borrow_direct_eligible' do
        expect(subject.borrow_direct_eligible?).to be false
      end
    end
  end

  context 'Multi-holding record with charged items and items available at restricted locations' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9696811',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#has_loanable_copy?' do
      it "should have available copy" do
        expect(subject.has_loanable_copy?).to be false
      end
    end

    describe '#borrow_direct_eligible?' do
      it 'should not be borrow_direct_eligible' do
        expect(subject.borrow_direct_eligible?).to be true
      end
    end
  end

  ### Review this test
  context 'RBSC Items and Borrow Direct' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2631265',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#borrow_direct_eligible?' do
      it 'should be borrow_direct_eligible?' do
        expect(subject.borrow_direct_eligible?).to be true
      end
    end

    describe '#isbn_numbers?' do
      it 'returns false when there are no isbns present' do
        expect(subject.isbn_numbers?).to be false
      end
    end
  end

  context 'When a barcode only user visits the site' do
    let(:user) { FactoryGirl.build(:valid_barcode_patron) }
    let(:params) {
      {
        system_id: '495501',
        mfhd: '538750',
        user: user
      }
    }
    let(:request) { described_class.new(params) }
    subject { request }
    describe '#requestable' do
      it "should have an requestable items" do
        expect(subject.requestable.size).to be >= 1
      end
    end
  end

  context "When passed mfhd and source params" do
    let(:user) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) {
      {
        system_id: '1969881',
        mfhd: '2246633',
        source: 'pulsearch',
        user: user
      }
    }
    let(:request_with_optional_params) { described_class.new(params) }
    subject { request_with_optional_params }

    describe "#request" do
      it "should have accessible mfhd param" do
        expect(subject.mfhd).to eq('2246633')
      end

      it "should have accessible source param" do
        expect(subject.source).to eq('pulsearch')
      end
    end
  end

  context "When passed an ID for a preservation office location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '9712355',
        user: user
      }
    }
    let(:request_for_preservation) { described_class.new(params) }
    subject { request_for_preservation }
    describe "#requestable" do
      it "should have a preservation location code" do
        expect(subject.requestable[0].location['code']).to eq('pres')
      end
    end
  end

  context 'A borrow Direct item that is not available' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '10140054',
        user: user
      }
    }
    let(:request_with_title_author) { described_class.new(params) }
    subject { request_with_title_author }

    describe '#fallback_query_params' do
      it 'has a title and author parameters when both are present' do
        expect(subject.fallback_query_params.key? :title).to be true
        expect(subject.fallback_query_params.key? :author).to be true
      end
    end

    describe '#fallback_query' do
      it 'returns a borrow direct fallback query url' do
        expect(subject.fallback_query).to be_truthy
        expect(subject.fallback_query).to include(::BorrowDirect::Defaults.html_base_url)
        expect(subject.fallback_query).to include(CGI.escape(subject.fallback_query_params[:title].downcase))
      end
    end
  end

  context "When passed a system_id for a record with a single aeon holding" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '4693146',
        user: user
      }
    }
    let(:request_with_single_aeon_holding) { described_class.new(params) }
    subject { request_with_single_aeon_holding }

    describe "#requestable" do
      describe "#has_single_aeon_requestable?" do
        it "should identify itself as a single aeon requestable" do
          expect(subject.has_single_aeon_requestable?).to be_truthy
        end
      end
    end
  end

  context "When passed a system_id for a record with a mixed holding, one of which has no item data and is at an annex." do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '2286894',
        user: user
      }
    }
    let(:request_with_fill_in_eligible_holding) { described_class.new(params) }
    subject { request_with_fill_in_eligible_holding }

    describe "#requestable" do
      describe "#fill_in_eligible" do
        it "should identify any mfhds that require fill in option" do
          expect(subject.fill_in_eligible.include? "2576882").to be_truthy
        end
      end
    end
  end

  context "When passed a system_id for a record with enumerable items at annex" do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '3845517',
        user: user
      }
    }
    let(:request_with_fill_in_eligible_holding) { described_class.new(params) }
    subject { request_with_fill_in_eligible_holding }

    describe "#requestable" do
      describe "#fill_in_eligible" do
        it "should identify any mfhds that require fill in option" do
          expect(subject.fill_in_eligible.include? "4148813").to be_truthy
        end
      end
    end
  end

  context "A SCSB id with a single holding" do
    let(:user) { FactoryGirl.build(:user) }
    let(:scsb_single_holding_item) { fixture('/SCSB-5290772.json') }
    let(:location_code) { 'scsbcul' }
    let(:params) {
      {
        system_id: 'SCSB-5290772',
        user: user,
        source: 'pulsearch'
      }
    }
    let(:scsb_availability_params) {
      {
        bibliographicId: "12134967",
        institutionId: "CUL"
      }
    }
    let(:scsb_availability_response) { fixture('/scsb_single_avail.json') }
    let(:request_scsb) { described_class.new(params) }
    subject { request_scsb }
    before(:each) do
      stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{params[:system_id]}.json")
        .to_return(status: 200, body: scsb_single_holding_item, headers: {})
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
        .to_return(status: 200, body: scsb_availability_response)
    end
    describe '#requestable' do
      it 'should have one requestable item' do
        expect(subject.requestable.size).to eq(1)
      end
    end
    describe '#other_id' do
      it 'should provide an other id value' do
        expect(subject.other_id).to eq('12134967')
      end
    end
    describe '#scsb_owning_institution' do
      it 'should provide the SCSB owning institution ID' do
        expect(subject.scsb_owning_institution(location_code)).to eq('CUL')
      end
    end
  end
end
