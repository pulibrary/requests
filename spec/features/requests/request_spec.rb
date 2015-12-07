require 'spec_helper'

describe 'request' do
  let(:request) { FactoryGirl.create(:request) }
  describe 'When visiting with a system ID' do
    before do
      visit '/requests'
    end

    it "Displays a Not Valid System ID error" do
      expect(page).to have_content "Please Supply a valid Library ID to Request"
    end
  end
end
