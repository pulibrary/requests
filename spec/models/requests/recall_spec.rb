require 'spec_helper'

describe Requests::Recall, type: :controller, vcr: { cassette_name: 'recall_request', record: :new_episodes } do
  context 'Recall Request' do
    let(:user_info) do
      {
        "user_name" => "Foo Request",
        "user_last_name" => "Request",
        "user_barcode" => "22101007797777",
        "email" => "foo@princeton.edu",
        "source" => "pulsearch",
        "patron_id" => "12345",
        "patron_group" => "staff"
      }
    end
    let(:requestable) do
      [{ "selected" => "true",
         "mfhd" => "5039570",
         "call_number" => "P93.5 .T847 2006",
         "location_code" => "f",
         "item_id" => "4428451",
         "barcode" => "32101061133466",
         "copy_number" => "1",
         "status" => "Renewed",
         "type" => "recall",
         "pickup" => "299|Firestone Circulation" }]
    end

    let(:bib) do
      {
        "id" => "4815239",
        "title" => "Beautiful evidence",
        "author" => "Tufte, Edward R.",
        "date" => "2006"
      }
    end

    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission) do
      Requests::Submission.new(params)
    end

    let(:todays_date) { Time.zone.today }
    let(:recall_request) { described_class.new(submission) }

    let(:responses) do
      {
        error: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>Failed to create request</reply-text><reply-code>25</reply-code><create-recall><note type=\"error\">No recall policy is defined for this item.</note></create-recall></response>",
        success: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-recall><note type=\"\">Your request was successful.</note></create-recall></response>"
      }
    end

    describe 'All Recall Requests' do
      let(:stub_url) do
        Requests.config[:voyager_api_base] + "/vxws/record/" + submission.bib['id'] +
          "/items/" + submission.items[0]['item_id'] +
          "/recall?patron=" + submission.user['patron_id'] +
          "&patron_group=" + submission.user['patron_group'] +
          "&patron_homedb=" + URI.escape('1@DB')
      end

      it "captures errors when the request is unsuccessful or malformed." do
        stub_request(:put, stub_url).
          # with(headers: { 'Accept' => '*/*' }).
          to_return(status: 405, body: responses[:error], headers: {})
        expect(recall_request.submitted.size).to eq(0)
        expect(recall_request.errors.size).to eq(1)
      end

      it "captures successful request submissions." do
        stub_request(:put, stub_url)
          .with(headers: { 'X-Accept' => 'application/xml' })
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(recall_request.submitted.size).to eq(1)
        expect(recall_request.errors.size).to eq(0)
      end

      it 'constructs a expiration date for the recall request' do
        stub_request(:put, stub_url)
          .with(headers: { 'X-Accept' => 'application/xml' })
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(recall_request.request_payload(submission.items.first)).to include("<last-interest-date>#{recall_request.expiration_date(60)}</last-interest-date>")
      end

      it 'has an expiry date 60 days from today formatted as yyyy-mm-dd' do
        stub_request(:put, stub_url)
          .with(headers: { 'X-Accept' => 'application/xml' })
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(recall_request.expiration_date(60)).to eq((todays_date + 60).strftime("%Y%m%d"))
      end
    end
  end
end
