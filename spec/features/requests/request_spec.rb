require 'spec_helper'

describe 'request', vcr: { cassette_name: 'request_features', record: :new_episodes } do

  let(:unauthenticated_patron) { FactoryGirl.build(:unauthenticated_patron) }
  let(:recap_id) { '9944355' }
  let(:in_process) { '9646099' }
  let(:voyager_id) { '9493318' }
  let(:thesis_id) { 'dsp01rr1720547' }

  describe 'When visiting without a system ID' do
    it "Displays a Not Valid System ID error" do
      visit '/requests'
      expect(page).to have_content "Please Supply a valid Library ID to Request"
    end
  end

  describe 'When unauthenticated patron visits a request item', js: true do

    it "displays three authentication options" do
      visit '/requests/9944355'
      expect(page).to have_content(I18n.t('requests.account.netid_login_msg'))
      expect(page).to have_content(I18n.t('requests.account.barcode_login_msg'))
      expect(page).to have_content(I18n.t('requests.account.other_user_login_msg'))
    end

  end

  describe 'When visiting a request item without logging in', js: true do

    it 'allows guest patrons to identify themselves and view the form' do
      visit '/requests/9944355'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      wait_for_ajax
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
      click_button 'Request this Item'
      wait_for_ajax
      expect(page).to have_content 'Request submitted'
    end

    it 'prohibits guest patrons from requesting In-Process items' do
      visit '/requests/9646099'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_content 'In Process'
      expect(page).to have_content 'Item is not requestable.'
    end

    it 'prohibits guest patrons from requesting On-Order items' do
      visit '/requests/10081566'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_content 'Item is not requestable.'
    end

    it 'allows guest patrons to access Online items' do
      visit '/requests/9994692'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_content 'www.jstor.org'
    end

    it 'allows guest patrons to request Aeon items' do
      visit '/requests/561774?mfhd=612742'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      click_link('Request to View in Reading Room')
      expect(page).to have_content 'Special Collections Research Account'
    end

    it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
      visit '/requests/1788796?mfhd=2053005'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_content 'Item is not requestable.'
    end

    it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
      visit '/requests/2286894'
      click_link(I18n.t('requests.account.other_user_login_msg'))
      fill_in 'request_email', :with => 'name@email.com'
      fill_in 'request_user_name', :with => 'foobar'
      click_button I18n.t('requests.account.other_user_login_btn')
      expect(page).to have_field 'requestable__selected', disabled: false
      expect(page).to have_field 'requestable_selected_7484608', disabled: true
      check('requestable__selected')
      click_button 'Request Selected Items'
      wait_for_ajax
      expect(page).to have_content 'Request submitted'
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
