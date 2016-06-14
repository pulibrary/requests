require 'spec_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :new_episodes } do

  context "as bibliographic record from voyager stored at recap that has an item record" do
    describe "#location_code" do
      it "returns a value voyager locatoin code." do
      end
    end

    describe "#voyager_managed?" do
    end
  end

  context "as a bibliographic record from voyager stored at the annex" do
  end

  context "as a bibliographic record from voyager, a print holding, and an item record that does not circulate" do
    let(:item) {
      {
        id: 4465718,
        status: "Not Charged",
        on_reserve: "N",
        copy_number: 1,
        temp_location: false,
        perm_location: "ctsn",
        enum: false,
        chron: false,
        item_sequence_number: 1,
        status_date: "2006-12-15T11:24:27.000-04:00",
        barcode: "32101054160302"
      }
    }
    let(:location) {
      {
        label: "Cotsen Children's Library",
        code: "ctsn",
        aeon_location: true,
        recap_electronic_delivery_location: false,
        open: false,
        requestable: false,
        always_requestable: true,
        circulates: false,
        library: {
          label: "ReCAP",
          code: "recap"
        }
      }
    }
    let(:holding) {
      {
        
      }
    }
    let(:bib) {
      {

      }
    }
    let(:params) { { bib: { id: 1 }, holding: { id: 2 }, item: item, location: location } }
    let(:subject) { described_class.new(params) }

    it "has params needed for a Valid OpenURL" do
      expect(subject).to eq('foo')
    end

    it "has a summary for the holding" do
      expect(subject.holding.summary).to eq('foobar')
    end

    it "has an item status" do
      expect(subject.item.status).to eq ('ooo')
    end

    xit "identifies as a ReCAP Item" do
      expect(subject.recap?).to be_truthy
    end
  end

  context "Has a bibliographic record from voyager and a print holding, but no item record" do
    xit "has no item stats" do
    end
  end

  context "It is a bibliographic record that is on order." do
  end

  context "Is a bibliographic record from the thesis collection" do
    describe "#thesis?" do
      it "returns true when record is a senior thesis" do
      end
    end
  end

  context "Is a bibliographic record from the Graphic Arts collection" do
    describe "#visuals?" do
      it "returns true when record is a senior thesis" do
      end
    end
  end

  context "It is in a paging location" do
    let(:user) { FactoryGirl.build(:user) }
    let(:request) { FactoryGirl.build(:request_paging_available) }
    let(:requestable) { request.requestable }
    describe "#pageable?" do
      it "should return nil when item status is unavailable" do
        expect(requestable.size).to eq(1)
        # change status 
        requestable.first.item["status"] = 'Charged'
        expect(requestable.first.pageable?).to be_falsey
      end

      it "should return true when item status is available" do
        expect(requestable.size).to eq(1)
        expect(requestable.first.pageable?).to be_truthy
      end
    end
  end

end