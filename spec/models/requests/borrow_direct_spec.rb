require 'spec_helper'

describe Requests::BorrowDirect do
  let(:user_info) do
    {
      "user_name" => "Foo Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
  end
  let(:requestable) do
    [
      {
        "selected" => "true",
        "mfhd" => "534137",
        "call_number" => "HA202 .U581",
        "location_code" => "rcppa",
        "item_id" => "3059236",
        "delivery_mode_3059236" => "print",
        "barcode" => "32101044283008",
        "enum" => "2000 (13th ed.)",
        "copy_number" => "1",
        "status" => "Not Charged",
        "type" => "bd",
        "edd_start_page" => "",
        "edd_end_page" => "",
        "edd_volume_number" => "",
        "edd_issue" => "",
        "edd_author" => "",
        "edd_art_title" => "",
        "edd_note" => "",
        "pickup" => "Firestone Library"
      },
      {
        "selected" => "false"
      }
    ]
  end
  let(:bib) do
    {
      "id" => "491654",
      "title" => "County and city data book.",
      "author" => "United States",
      "date" => "1949"
    }
  end
  let(:bd) do
    {
      "auth_id" => 'foobarfoobar',
      "query_params" => '9780544343757'
    }
  end
  let(:params) do
    {
      request: user_info,
      requestable: requestable,
      bib: bib,
      bd: bd
    }
  end

  let(:submission) do
    Requests::Submission.new(params)
  end

  let(:good_request_response) { 'A BD Request Number' }
  let(:bad_request_response) { 'An error happened' }

  let(:borrow_direct) { described_class.new(submission) }

  it 'Handles a Borrow Direct request successfully' do
    allow(borrow_direct).to receive(:handle).and_return(good_request_response)
    borrow_direct.handle
    allow(borrow_direct).to receive(:sent).and_return(good_request_response)
    expect(borrow_direct.sent).to eq(good_request_response)
  end

  it 'Logs an error when a request fails' do
    allow(borrow_direct).to receive(:handle).and_return(bad_request_response)
    borrow_direct.handle
    allow(borrow_direct).to receive(:errors).and_return(bad_request_response)
    expect(borrow_direct.errors).to eq(bad_request_response)
  end
end
