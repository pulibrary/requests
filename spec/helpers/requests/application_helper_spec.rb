require 'spec_helper'
require './app/models/requests/request.rb'

RSpec.describe Requests::ApplicationHelper, type: :helper, vcr: { cassette_name: 'request_models', record: :new_episodes } do
  describe '#isbn_string' do
    let(:isbns) {
      [
        '9780544343757',
        '179758877'
      ]
    }
    let(:isbn_string) { helper.isbn_string(isbns) }
    it 'returns a list of formatted isbns' do
      expect(isbn_string).to eq('9780544343757,179758877')
    end
  end

  describe '#submit_disabled' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) {
      {
        system_id: '8179402',
        user: user
      }
    }
    let(:request_with_items_on_reserve) { Requests::Request.new(params) }
    let(:requestable_list) { request_with_items_on_reserve.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }

    it 'returns a boolean to disable/enable submit' do
      expect(submit_button_disabled).to be_truthy
    end
  end

  describe '#suppress_login' do
    let(:unauthenticated_patron) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) {
      {
        system_id: '7352936',
        mfhd: '7179463',
        user: unauthenticated_patron
      }
    }
    let(:aeon_only_request) { Requests::Request.new(params) }
    let(:login_suppressed) { helper.suppress_login(aeon_only_request) }

    it 'returns a boolean to disable/enable submit' do
      expect(login_suppressed).to be true
    end
  end
end
