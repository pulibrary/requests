require 'spec_helper'

describe Requests::HoldItem, type: :controller do
  context 'Hold Item Request' do
    let(:valid_patron) { { "netid" => "foo" }.with_indifferent_access }
    let(:user_info) do
      user = instance_double(User, guest?: false, uid: 'foo')
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end

    let(:requestable) do
      [{ "selected" => "true",
         "mfhd" => "22212632750006421",
         "call_number" => "HQ1532 .P44 2019",
         "location_code" => "f",
         "item_id" => "23212632740006421",
         "barcode" => "32101107924928",
         "copy_number" => "0",
         "status" => "Not Charged",
         "item_type" => "Gen",
         "pick_up_location_code" => "fcirc",
         "pick_up_location_id" => "489",
         "type" => "on_shelf" }]
    end

    let(:bib) do
      {
        "id" => "99114518363506421",
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
      Requests::Submission.new(params, user_info)
    end

    let(:todays_date) { Time.zone.today }
    let(:hold_request) { described_class.new(submission) }

    let(:responses) do
      {
        error: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>Failed to create request</reply-text><reply-code>25</reply-code><create-recall><note type=\"error\">No recall policy is defined for this item.</note></create-recall></response>",
        success: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-hold><note type=\"\">Your request was successful.</note></create-hold></response>",
        get: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><hold allowed=\"Y\"></hold></response>"
      }
    end

    describe 'All Hold Requests' do
      let(:stub_url) do
        Requests.config[:voyager_api_base] + "/vxws/record/" + submission.bib['id'] +
          "/items/" + submission.items[0]['item_id'] +
          "/hold?patron=" + submission.patron.patron_id.to_s +
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
        expect(hold_request.submitted.first[:payload]).to include("<pickup-location>489</pickup-location>")
      end

      it 'has an expiry date 60 days from today formatted as yyyy-mm-dd by default' do
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:get], headers: {})
        stub_request(:put, stub_url)
          .with(headers: { 'X-Accept' => 'application/xml' })
          .to_return(status: 201, body: responses[:success], headers: {})
        expect(hold_request.request_payload(submission.items.first)).to include("<last-interest-date>#{(todays_date + 60).strftime('%Y%m%d')}</last-interest-date>")
      end

      context "no pick-up id is present" do
        let(:requestable) do
          [{ "selected" => "true",
             "mfhd" => "22212632750006421",
             "call_number" => "HQ1532 .P44 2019",
             "location_code" => "f",
             "item_id" => "23212632740006421",
             "barcode" => "32101107924928",
             "copy_number" => "0",
             "status" => "Not Charged",
             "item_type" => "Gen",
             "pick_up_location_code" => "fcirc",
             "pick_up" => "PM",
             "type" => "on_shelf" }]
        end

        it 'has the correct pick-up location id' do
          stub_request(:get, stub_url)
            .to_return(status: 200, body: responses[:get], headers: {})
          stub_request(:put, stub_url)
            .with(headers: { 'X-Accept' => 'application/xml' })
            .to_return(status: 201, body: responses[:success], headers: {})
          expect(hold_request.request_payload(submission.items.first)).to include("<pickup-location>333</pickup-location>")
        end
      end
    end
  end
end
