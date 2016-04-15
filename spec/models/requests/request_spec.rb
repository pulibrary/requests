require 'spec_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :new_episodes } do

  context "When passed a system_id with a holding record with an item" do 

    let(:user) { FactoryGirl.build(:user) }
    let(:params) { 
      {
        system_id: '8880549',
        mfhd: '8805567',
        user: user
      }
    }
    let(:request_with_holding_item) { described_class.new(params) }
    subject { request_with_holding_item }

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(subject.requestable).to be_truthy
        expect(subject.requestable.size).to eq(1)
        expect(subject.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "Contains a requestable object with a holding" do
        expect(subject.requestable[0].holding).to be_truthy
      end

      it "Contains a requesable object with an item" do
        expect(subject.requestable[0].item).to be_truthy
      end
    end

    describe "#system_id" do
      it "has a system id" do
      end
    end

    describe "#load_items" do
    end
  end

  context "When passed a system_id with only a holding record" do
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
    end
  end

  context "When passed a system_id with no holdings or items" do
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
      it "has a list of request objects" do
        expect(subject.requestable).to be_falsy
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
    end
  end
  ## TODO
  ## Add context for Visuals when available
  ## Add context for EAD when available
end
