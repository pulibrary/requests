require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes } do

  let(:recap_id) { '9944355' }
  let(:voyager_id) { '9493318' }
  let(:thesis_id) { 'dsp01rr1720547' }

  describe 'When visiting without a system ID' do
    it "Displays a Not Valid System ID error" do
      visit '/requests'
      expect(page).to have_content "Please Supply a valid Library ID to Request"
    end
  end

  describe 'When visiting a request item without logging in' do

    it "displays three authentication options" do
      visit '/requests/9944355'
      expect(page).to have_content(I18n.t('requests.account.netid_login_msg'))
      expect(page).to have_content(I18n.t('requests.account.barcode_login_msg'))
      expect(page).to have_content(I18n.t('requests.account.other_user_login_msg'))
    end

    it 'allows guest patrons to identify themselves and view the form' do
      visit '/requests/9944355'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
    end

    it 'allows guest patrons to request a physical recap item' do
      visit '/requests/9944355'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_no_content 'Electronic Delivery'
      select('Firestone Library', :from => 'requestable__pickup')
      #click_button 'Request this Item'
    end

  end
  # # when current_user is available test these
  # describe 'When visitng with a system id' do
  #   it 'from Voyager' do
  #     visit '/requests/9493318'
  #     expect(page).to have_content voyager_id
  #   end

  #   it 'from a Theses' do
  #     visit "/requests/#{thesis_id}"
  #     expect(page).to have_content thesis_id
  #   end
  # end

end
