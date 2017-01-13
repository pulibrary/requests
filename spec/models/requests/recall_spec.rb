require 'spec_helper'

describe Requests::Recall do

    context 'Recall Request' do
        let(:user_info) {
          {
            "user_name"=>"Foo Request",
            "user_last_name"=>"Request",
            "user_barcode"=>"22101007797777",
            "email"=>"foo@princeton.edu",
            "source"=>"pulsearch",
            "patron_id"=>"12345",
            "patron_group"=>"staff"}
        }
        let(:requestable) {
            [{"selected"=>"true",
              "mfhd"=>"5039570",
              "call_number"=>"P93.5 .T847 2006",
              "location_code"=>"f",
              "item_id"=>"4428451",
              "barcode"=>"32101061133466",
              "copy_number"=>"1",
              "status"=>"Renewed",
              "type"=>"recall",
              "pickup"=>"299|Firestone Circulation"}]
        }

        let(:bib) {
          {
            "id"=>"4815239",
            "title"=>"Beautiful evidence",
            "author"=>"Tufte, Edward R.",
            "date"=>"2006"}
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

        let(:responses) {
          {
          error: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>Failed to create request</reply-text><reply-code>25</reply-code><create-recall><note type=\"error\">No recall policy is defined for this item.</note></create-recall></response>",
          success: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-recall><note type=\"\">Your request was successful.</note></create-recall></response>"
          }
        }


    describe 'All Recall Requests' do

        before(:each) do
         @stub_url = Requests.config[:voyager_api_base] + "/vxws/record/" + submission.bib['id'] +
                     "/items/" + submission.items[0]['item_id'] +
                     "/recall?patron=" + submission.user['patron_id'] +
                     "&patron_group=" + submission.user['patron_group'] +
                     "&patron_homedb=" + URI.escape(Requests.config[:voyager_ub_id])
        end

        it "It should capture errors when the request is unsuccessful or malformed." do

            stub_request(:put, @stub_url).
              with(headers: {'Accept'=>'*/*'}).
              to_return(status: 405, body: responses[:error], headers: {})

              expect(subject.submitted.size).to eq(0)
              expect(subject.errors.size).to eq(1)
        end

        it "It should capture successful request submissions." do

            stub_request(:put, @stub_url).
              with(headers: {'Accept'=>'*/*'}).
              to_return(status: 201, body: responses[:success], headers: {})

            expect(subject.submitted.size).to eq(1)
            expect(subject.errors.size).to eq(0)
        end

    end

  end

end
