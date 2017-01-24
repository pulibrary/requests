require 'spec_helper'

describe Requests do
  it 'has a version number' do
    expect(Requests::VERSION).to be_a(String)
  end
end