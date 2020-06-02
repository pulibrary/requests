require 'spec_helper'

describe Requests::HoldItem, type: :controller do
  context 'Hold Item Request' do
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
         "mfhd" => "9723988",
         "call_number" => "HQ1532 .P44 2019",
         "location_code" => "f",
         "item_id" => "8183358",
         "barcode" => "32101107924928",
         "copy_number" => "0",
         "status" => "Not Charged",
         "type" => "on_shelf",
         "pickup" => "299|Firestone Circulation" }]
    end

    let(:bib) do
      {
        "id" => "11451836",
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
    let(:hold_request) { described_class.new(submission) }

    let(:responses) do
      {
        error: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>Failed to create request</reply-text><reply-code>25</reply-code><create-recall><note type=\"error\">No recall policy is defined for this item.</note></create-recall></response>",
        success: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-hold><note type=\"\">Your request was successful.</note></create-hold></response>",
        get: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><hold allowed=\"Y\"></hold></response>",
        get_error: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code></response>",
        get_error_items: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><hold allowed=\"N\" note=\"Could not retrieve items for request.\"></hold></response>"
      }
    end

    describe 'All Hold Requests' do
      let(:stub_url) do
        Requests.config[:voyager_api_base] + "/vxws/record/" + submission.bib['id'] +
          "/items/" + submission.items[0]['item_id'] +
          "/hold?patron=" + submission.user['patron_id'] +
          "&patron_homedb=" + URI.escape('1@DB')
      end

      let(:stub_url_no_item) do
        Requests.config[:voyager_api_base] + "/vxws/record/" + submission.bib['id'] +
          "/hold?patron=" + submission.user['patron_id'] +
          "&patron_homedb=" + URI.escape('1@DB')
      end

      it "captures errors when the request is unsuccessful or malformed." do
        stub_request(:put, stub_url).
          # with(headers: { 'Accept' => '*/*' }).
          to_return(status: 405, body: responses[:error], headers: {})
        stub_request(:get, stub_url).
          # with(headers: { 'Accept' => '*/*' }).
          to_return(status: 405, body: responses[:get], headers: {})
        expect(hold_request.submitted.size).to eq(0)
        expect(hold_request.errors.size).to eq(1)
      end

      it "captures successful request submissions." do
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:get], headers: {})
        stub_request(:put, stub_url)
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(hold_request.submitted.size).to eq(1)
        expect(hold_request.errors.size).to eq(0)
        expect(hold_request.submitted.first[:payload]).to include("<last-interest-date>#{(todays_date + 7).strftime('%Y%m%d')}</last-interest-date>")
      end

      it "captures error with hold check" do
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:get_error], headers: {})
        expect(hold_request.submitted.size).to eq(0)
        expect(hold_request.errors.size).to eq(1)
      end

      it "captures an item error and tries a title hold request submissions." do
        bib["id"] = '10574699'
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:get_error_items], headers: {})
        stub_request(:get, stub_url_no_item)
          .to_return(status: 200, body: responses[:get], headers: {})
        stub_request(:put, stub_url_no_item)
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(hold_request.submitted.size).to eq(1)
        expect(hold_request.errors.size).to eq(0)
        expect(hold_request.submitted.first[:payload]).to include("<last-interest-date>#{(todays_date + 7).strftime('%Y%m%d')}</last-interest-date>")
      end

      it 'has an expiry date 60 days from today formatted as yyyy-mm-dd by default' do
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:get], headers: {})
        stub_request(:put, stub_url)
          .with(headers: { 'X-Accept' => 'application/xml' })
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(hold_request.request_payload(submission.items.first)).to include("<last-interest-date>#{(todays_date + 60).strftime('%Y%m%d')}</last-interest-date>")
      end
    end
  end
end
