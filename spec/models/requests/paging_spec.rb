require 'spec_helper'

describe Requests::Paging do
  let(:params) {
    {
      type: "paging"
    }
  }
  let(:subject) { described_class.new(params) }
  it "has a type" do
    expect(subject.type).to eq('paging')
  end

end