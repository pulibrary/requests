require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes } do

  let(:voyager_id) { '9493318' }
  let(:thesis_id) { 'dsp01rr1720547' }
  
  describe 'When visiting without a system ID' do
    it "Displays a Not Valid System ID error" do
      visit '/requests'
      expect(page).to have_content "Please Supply a valid Library ID to Request"
    end
  end

  # when current_user is available test these
  describe 'When visitng with a system id' do
    xit 'from Voyager' do
      visit '/requests/9493318'
      expect(page).to have_content voyager_id
    end

    xit 'from a Theses' do
      visit "/requests/#{thesis_id}"
      expect(page).to have_content thesis_id
    end
  end

end
