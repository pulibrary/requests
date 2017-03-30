require 'spec_helper'

describe Requests::BorrowDirect do
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
        "delivery_mode_3059236"=>"print",
        "barcode"=>"32101044283008",
        "enum"=>"2000 (13th ed.)",
        "copy_number"=>"1",
        "status"=>"Not Charged",
        "type"=>"bd",
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
      "date"=>"1949",
    }
  }
  let(:bd) {
    {
      "auth_id" => 'foobarfoobar',
      "query_params" => '9780544343757'
    }
  }
  let(:params) {
    {
      request: user_info,
      requestable: requestable,
      bib: bib,
      bd: bd
    }
  }

  let(:submission) {
    Requests::Submission.new(params)
  }
  
  let(:good_request_response) { 'A BD Request Number' }
  let(:bad_request_response) { 'An error happened' }

  let(:subject) { described_class.new(submission) }

  it 'Handles a Borrow Direct request successfully' do
    allow(subject).to receive(:handle).and_return(good_request_response)
    subject.handle
    allow(subject).to receive(:sent).and_return(good_request_response)
    expect(subject.sent).to eq(good_request_response)
  end

  it 'Logs an error when a request fails' do
    allow(subject).to receive(:handle).and_return(bad_request_response)
    subject.handle
    allow(subject).to receive(:errors).and_return(bad_request_response)
    expect(subject.errors).to eq(bad_request_response)
  end
end