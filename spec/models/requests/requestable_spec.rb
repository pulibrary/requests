require 'spec_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable_models', record: :new_episodes } do do

  describe "as a bibliographic record from voyager, a print holding, and an item record" do
    let(:params) { { bib: { id: 1 }, holding: { id: 2 }, item: { id: 3, barcode: 12133 }, location: {} } }
    let(:subject) { described_class.new(params) }

    it "has params needed for a Valid OpenURL" do
      expect(subject.title).to eq('foo')
    end

    it "has a summary for the holding" do
      expect(subject.holding.summery).to eq('foobar')
    end

    it "has an item status" do
      expect(subject.item.status).to eq ('ooo')
    end
  end

  describe "Has a bibliographic record from voyager and a print holding, but no item record" do
    it "has no item stats" do
    end
  end

  describe "It is a bibliographic record that is on order." do
  end

  describe "Is a bibliographic record from the thesis collection" do
  end

  describe "Is a bibliographic record from the Graphic Arts collection" do
  end

  describe "Is a bibliographic record from a Fiding Aid" do
  end

end