require 'spec_helper'

describe Requests::Recap do
  context 'ReCAP Request' do
  let(:user_info) {
    {
      "user_name" => "Foo Request",
      "user_last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch" }
  }
  let(:requestable) {
    [{ "selected" => "true",
       "mfhd" => "534137",
       "call_number" => "HA202 .U581",
       "location_code" => "rcppa",
       "item_id" => "6067274",
       "barcode" => "32101082413400",
       "enum" => "1956",
       "copy_number" => "1",
       "status" => "Not Charged",
       "type" => "recap",
       "delivery_mode_6067274" => "print",
       "edd_start_page" => "",
       "edd_end_page" => "",
       "edd_volume_number" => "",
       "edd_issue" => "",
       "edd_author" => "",
       "edd_art_title" => "",
       "edd_note" => "",
       "pickup" => "PA" },
       { "selected" => "true",
         "mfhd" => "534137",
         "call_number" => "HA202 .U581",
         "location_code" => "rcppa",
         "item_id" => "3147971",
         "barcode" => "32101094934260",
         "enum" => "1947",
         "copy_number" => "1",
         "status" => "Not Charged",
         "type" => "recap",
         "delivery_mode_3147971" => "edd",
         "edd_start_page" => "1",
         "edd_end_page" => "",
         "edd_volume_number" => "",
         "edd_issue" => "",
         "edd_author" => "",
         "edd_art_title" => "Baz",
         "edd_note" => "",
         "pickup" => "PH" }]
  }

  let(:bib) {
    {
      "id" => "491654",
      "title" => "County and city data book.",
      "author" => "United States",
      "date" => "1949"
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

  let(:subject) { described_class.new(submission) }
  let(:good_request) { fixture('/scsb_find_request.json') }
  let(:good_response) { fixture('/scsb_request_item_response.json') }
  let(:bad_response) { fixture('/scsb_request_item_response_errors.json') }

  describe 'All ReCAP Requests' do
    it "It should capture errors when the request is unsuccessful or malformed." do
      stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
        # with(headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
        to_return(status: 401, body: "Unauthorized", headers: {})
      expect(subject.submitted.size).to eq(0)
      expect(subject.errors.size).to eq(2)
    end

    it "It should capture errors when response is a 200 but the request is unsuccessful" do
      stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
        # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
        to_return(status: 200, body: bad_response, headers: {})
      expect(subject.submitted.size).to eq(0)
      expect(subject.errors.size).to eq(2)
    end

    it "It should capture successful request submissions." do
      stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
        # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
        to_return(status: 200, body: good_response, headers: {})
      expect(subject.submitted.size).to eq(2)
      expect(subject.errors.size).to eq(0)
    end
  end
end
end
