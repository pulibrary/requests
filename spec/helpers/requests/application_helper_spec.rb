require 'spec_helper'
require './app/models/requests/request.rb'

RSpec.describe Requests::ApplicationHelper, type: :helper, vcr: { cassette_name: 'request_models', record: :new_episodes } do
  describe '#isbn_string' do
    let(:isbns) do
      [
        '9780544343757',
        '179758877'
      ]
    end
    let(:isbn_string) { helper.isbn_string(isbns) }
    it 'returns a list of formatted isbns' do
      expect(isbn_string).to eq('9780544343757,179758877')
    end
  end

  describe '#submit_disabled' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '8179402',
        user: user
      }
    end
    let(:request_with_items_on_reserve) { Requests::Request.new(params) }
    let(:requestable_list) { request_with_items_on_reserve.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }

    it 'returns a boolean to disable/enable submit' do
      expect(submit_button_disabled).to be_truthy
    end

    # temporary for #348
    context "Firestone Classics Collection (Clas)" do
      let(:params) do
        {
          system_id: '9222024',
          user: user
        }
      end
      it 'returns a boolean to enable submit for logged in user' do
        assign(:user, user)
        expect(submit_button_disabled).to be_falsey
      end

      it 'returns a boolean to disable submit for guest' do
        assign(:user, nil)
        expect(submit_button_disabled).to be_truthy
      end
    end

    describe 'lewis library' do
      let(:params) do
        {
          system_id: '3848872',
          user: user
        }
      end
      it 'lewis is a submitable request' do
        expect(submit_button_disabled).to be false
      end
    end
  end

  describe 'firestone pickup_choices' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '491654',
        mfhd: '534140',
        user: user
      }
    end
    let(:default_pickups) do
      [{ label: "Firestone Library", gfa_code: "PA", staff_only: false }, { label: "Architecture Library", gfa_code: "PW", staff_only: false }, { label: "East Asian Library", gfa_code: "PL", staff_only: false }, { label: "Lewis Library", gfa_code: "PN", staff_only: false }, { label: "Marquand Library of Art and Archaeology", gfa_code: "PJ", staff_only: false }, { label: "Mendel Music Library", gfa_code: "PK", staff_only: false }, { label: "Plasma Physics Library", gfa_code: "PQ", staff_only: false }, { label: "Stokes Library", gfa_code: "PM", staff_only: false }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::Request.new(params) }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }
    it 'lewis is a submitable request' do
      choices = helper.pickup_choices(lewis_request_with_multiple_requestable.requestable.last, default_pickups)
      expect(choices).to eq("<div id=\"fields-print__3826440\" class=\"card card-body bg-light collapse show request--print\"><input type=\"hidden\" name=\"requestable[][pickup]\" id=\"requestable__pickup\" value=\"PN\" class=\"single-pickup-hidden\" /><label class=\"single-pickup\" style=\"\" for=\"requestable__pickup\">Pickup location: Firestone Library</label></div>")
    end
  end

  describe 'multiple delivery options' do
    let(:user) { FactoryGirl.build(:user) }
    let(:params) do
      {
        system_id: '426420',
        mfhd: '3538795',
        user: user
      }
    end
    let(:default_pickups) do
      [{ label: "Firestone Library", gfa_code: "PA", staff_only: false }, { label: "Architecture Library", gfa_code: "PW", staff_only: false }, { label: "East Asian Library", gfa_code: "PL", staff_only: false }, { label: "Lewis Library", gfa_code: "PN", staff_only: false }, { label: "Marquand Library of Art and Archaeology", gfa_code: "PJ", staff_only: false }, { label: "Mendel Music Library", gfa_code: "PK", staff_only: false }, { label: "Plasma Physics Library", gfa_code: "PQ", staff_only: false }, { label: "Stokes Library", gfa_code: "PM", staff_only: false }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::Request.new(params) }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled(requestable_list) }
    it 'lewis is a submitable request' do
      choices = helper.pickup_choices(lewis_request_with_multiple_requestable.requestable.last, default_pickups)
      expect(choices).to eq("<div id=\"fields-print__2578961\" class=\"card card-body bg-light collapse show request--print\"><input type=\"hidden\" name=\"requestable[][pickup]\" id=\"requestable__pickup\" value=\"PA\" class=\"single-pickup-hidden\" /><label class=\"single-pickup\" style=\"\" for=\"requestable__pickup\">Pickup location: Firestone Library</label></div>")
    end
  end

  describe '#suppress_login' do
    let(:unauthenticated_patron) { FactoryGirl.build(:unauthenticated_patron) }
    let(:params) do
      {
        system_id: '7352936',
        mfhd: '7179463',
        user: unauthenticated_patron
      }
    end
    let(:aeon_only_request) { Requests::Request.new(params) }
    let(:login_suppressed) { helper.suppress_login(aeon_only_request) }

    it 'returns a boolean to disable/enable submit' do
      expect(login_suppressed).to be true
    end
  end

  describe '#hidden_fields_mfhd' do
    let(:mfhd) do
      {
        "location" => "ReCAP - Use in Firestone Microforms only",
        "library" => "ReCAP",
        "location_code" => "rcppf",
        "copy_number" => "1",
        "call_number" => "MICROFILM S00534",
        "call_number_browse" => "MICROFILM S00534",
        "location_has" => [
          "No. 22 (Mar. 10/17 1969)-no. 47 (Oct. 6, 1969)",
          "No. 22-47 on reel with no. 1-21 of the earlier title."
        ]
      }
    end

    it 'generates the <input type="hidden"> element markup using MFHD values' do
      expect(helper.hidden_fields_mfhd(mfhd)).to eq \
        "<input type=\"hidden\" name=\"mfhd[][call_number]\" id=\"mfhd__call_number\" value=\"MICROFILM S00534\" /><input type=\"hidden\" name=\"mfhd[][location]\" id=\"mfhd__location\" value=\"ReCAP - Use in Firestone Microforms only\" /><input type=\"hidden\" name=\"mfhd[][library]\" id=\"mfhd__library\" value=\"ReCAP\" />"
    end

    context 'when the MFHD is nil' do
      it 'generates no markup' do
        expect(helper.hidden_fields_mfhd(nil)).to be_empty
      end
    end
  end
end
