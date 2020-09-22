require 'spec_helper'

describe Requests::Recap do
  context 'ReCAP Request' do
    let(:valid_patron) { { "netid" => "foo" }.with_indifferent_access }
    let(:user_info) do
      user = instance_double(User, guest?: false, uid: 'foo')
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end
    let(:requestable) do
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
         "library_code" => "recap",
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
         "library_code" => "recap",
         "pickup" => "PH" }]
    end

    let(:bib) do
      {
        "id" => "491654",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
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

    let(:recap_request) { described_class.new(submission) }
    let(:good_request) { fixture('/scsb_find_request.json') }
    let(:good_response) { fixture('/scsb_request_item_response.json') }
    let(:bad_response) { fixture('/scsb_request_item_response_errors.json') }

    describe 'All ReCAP Requests' do
      it "captures errors when the request is unsuccessful or malformed." do
        stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
          # with(headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 401, body: "Unauthorized", headers: {})
        expect(recap_request.submitted.size).to eq(0)
        expect(recap_request.errors.size).to eq(2)
      end

      it "captures errors when response is a 200 but the request is unsuccessful" do
        stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: bad_response, headers: {})
        expect(recap_request.submitted.size).to eq(0)
        expect(recap_request.errors.size).to eq(2)
      end

      it "captures successful request submissions." do
        stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: good_response, headers: {})
        expect(recap_request.submitted.size).to eq(2)
        expect(recap_request.errors.size).to eq(0)
      end

      context 'when the SCSB web service responds with an invalid response' do
        subject(:recap) { described_class.new(submission) }

        before(:context) do
          stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem").to_return(status: 200, body: '{invalid', headers: {})
        end

        it 'logs an error' do
          allow(Rails.logger).to receive(:error)

          expect(recap.submitted.size).to eq(0)
          expect(recap.errors.size).to eq(2)
          expect(Rails.logger).to have_received(:error).with(/Invalid response from the SCSB server/).twice
        end
      end
    end
  end
end
