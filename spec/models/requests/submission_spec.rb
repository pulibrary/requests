require 'spec_helper'

describe Requests::Submission, vcr: { cassette_name: 'submissions', record: :new_episodes } do
  
  context 'A valid submission' do
    let(:user_info) {
      {
        "user_name"=>"Foo Request", 
        "user_barcode"=>"22101007797777", 
        "email"=>"foo@princeton.edu", 
        "source"=>"pulsearch"}

    }
    let(:requestable) {
      [
        {
          "selected"=>"true",
          "mfhd"=>"534137",
          "call_number"=>"HA202 .U581",
          "location_code"=>"rcppa",
          "item_id"=>"3059236",
          "barcode"=>"32101044283008",
          "enum"=>"2000 (13th ed.)",
          "copy_number"=>"1",
          "status"=>"Not Charged",
          "type"=>"recap",
          "edd_start_page"=>"",
          "edd_end_page"=>"",
          "edd_volume_number"=>"",
          "edd_issue"=>"",
          "edd_author"=>"",
          "edd_art_title"=>"",
          "edd_note"=>"",
          "pickup"=>"Firestone Library"
        },
        {
          "selected"=>"false",
        }
      ]
    }
    let(:bib) {
      {
        "id"=>"491654", 
        "title"=>"County and city data book.", 
        "author"=>"United States", 
        "date"=>"1949"
      }
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }
    let(:submission) {
      Requests::Submission.new(params)
    }

    describe "includes" do
      it "has a user barcode" do
        expect(submission.user_barcode).to be_truthy
      end

      xit "a user name" do
      end

      xit "a user email address" do
      end

      xit "does not include any error messages" do
      end

      xit "It has one or more items requested attached. " do
      end

      xit "It has basic bibliographic information for a requested title" do
      end

      xit "It has one service type" do
      end
    end
  end

  context 'An invalid Submission' do
    describe 'includes error messsages' do
    end

    describe 'contains invalid items' do
    end
  end


  context 'ReCAP Request' do
    
    describe 'Print Request' do
    end

    describe 'EDD Request' do
    end
  end

  context 'Borrow Direct Eligible Item' do
  end

  context 'Recall' do
  end

  context 'Submission with User Supplied Data' do
    describe 'Valid user Supplied Data' do
    end

    describe 'Invalid User Supplied Data' do
    end
  end

end