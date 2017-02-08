require 'spec_helper'

describe Requests::Submission do

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
          "delivery_mode_3059236"=>"print",
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
      it "is a valid submission with no errors" do
        expect(submission.valid?).to be_truthy
        expect(submission.errors.full_messages.size).to eq(0)
      end

      it "has a user barcode" do
        expect(submission.user_barcode).to be_truthy
      end

      it "has a user name" do
        expect(submission.user_name).to be_truthy
      end

      it "a user email address" do
        expect(submission.email).to be_truthy
      end

      it "It has one or more items requested attached. " do
        expect(submission.items).to be_truthy
        expect(submission.items).to be_an(Array)
        expect(submission.items.size).to be > 0
      end

      it "It has basic bibliographic information for a requested title" do
        expect(submission.bib['id']).to be_truthy
      end

      it "It has one service type" do
        expect(submission.service_types).to be_truthy
        expect(submission.service_types).to be_an(Array)
      end
    end
  end

  context 'An invalid Submission' do
      let(:user_info) {
        {
          "user_name"=>"Foo",
          "user_barcode"=>"Bar",
          "email"=>"baz",
          "source"=>"pulsearch"}

      }

      let(:bib) {
        {
          "id"=>""
        }
      }

      let(:invalid_params) {
          {
              request: user_info,
              requestable: [ { "selected"=>"true" } ],
              bib: bib
          }
      }

      let(:invalid_submission) {
        Requests::Submission.new(invalid_params)
      }

    describe "invalid" do
        it 'includes error messsages' do
            expect(invalid_submission.valid?).to be_falsy
            expect(invalid_submission.errors.full_messages.size).to be > 0
        end
    end
  end

  context 'Recap' do
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
            "type"=>"recap",
            "edd_start_page"=>"",
            "edd_end_page"=>"",
            "edd_volume_number"=>"",
            "edd_issue"=>"",
            "edd_author"=>"",
            "edd_art_title"=>"",
            "edd_note"=>"",
            "pickup"=>"PA"
          },
          {
              "selected"=>"true",
              "mfhd"=>"534137",
              "call_number"=>"HA202 .U581",
              "location_code"=>"rcppa",
              "item_id"=>"3059237",
              "delivery_mode_3059237"=>"edd",
              "barcode"=>"32101044283008",
              "enum"=>"2000 (13th ed.)",
              "copy_number"=>"1",
              "status"=>"Not Charged",
              "type"=>"recap",
              "edd_start_page"=>"1",
              "edd_end_page"=>"",
              "edd_volume_number"=>"",
              "edd_issue"=>"",
              "edd_author"=>"",
              "edd_art_title"=>"",
              "edd_note"=>"",
              "pickup"=>""
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

      describe "Print Delivery" do
         it 'items have gfa pickup location code' do
          expect(submission.items[0]['pickup']).to be_truthy
          expect(submission.items[0]['pickup']).to be_a(String)
          expect(submission.items[0]['pickup'].size).to eq(2)
         end
      end

      describe "Eletronic Delivery" do
          it 'items have a valid start page' do
           expect(submission.items[1]['edd_start_page']).to be_truthy
          end
      end

  end

  context 'Borrow Direct Eligible Item' do
  end

  context 'Recall' do
  end

  context 'Multiple Submission Types (Recap and Recall)' do

    let(:user_info) {
      {
        "user_name"=>"Foo Request",
        "user_barcode"=>"22101007797777",
        "email"=>"foo@princeton.edu",
        "source"=>"pulsearch",
        "patron_id"=>"12345",
        "patron_group"=>"staff"
      }
    }
    let(:requestable) {
      [
        {"selected"=>"true",
            "mfhd"=>"538419",
            "call_number"=>"GN670 .P74",
            "location_code"=>"rcppa",
            "item_id"=>"3710038",
            "barcode"=>"32101091858066",
            "enum"=>"vol. 5 (1896)",
            "copy_number"=>"1",
            "status"=>"Charged",
            "type"=>"recall",
            "pickup"=>"299|.Firestone Library Circulation Desk"
          },
          {
            "selected"=>"true",
            "mfhd"=>"538419",
            "call_number"=>"GN670 .P74",
            "location_code"=>"rcppa",
            "item_id"=>"3707281",
            "barcode"=>"32101091857142",
            "enum"=>"vol. 4 (1895)",
            "copy_number"=>"1",
            "status"=>"Not Charged",
            "type"=>"recap",
            "delivery_mode_3707281"=>"print",
            "pickup"=>"PA",
            "edd_start_page"=>"",
            "edd_end_page"=>"",
            "edd_volume_number"=>"",
            "edd_issue"=>"",
            "edd_author"=>"",
            "edd_art_title"=>"",
            "edd_note"=>""
          }
      ]
    }

    let(:bib) {
      {
        "id"=>"495220",
        "title"=>"Journal of the Polynesian Society.",
        "author"=>"Polynesian Society (N.Z.)",
        "date"=>"1892"
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

    describe "Mixed Service Types" do

      it 'recall items have voyager pickup location code' do
       pickup = submission.items[0]['pickup'].split("|")

       expect(submission.items[0]['pickup']).to be_truthy
       expect(pickup[0].to_i.to_s).to eq(pickup[0])
       expect(submission.items[0]['type']).to eq("recall")
       expect(submission.user['patron_id']).to be_truthy
       expect(submission.user['patron_group']).to be_truthy
      end

      it 'recap items have gfa pickup location code' do
        expect(submission.items[1]['pickup']).to be_truthy
        expect(submission.items[1]['pickup']).to be_a(String)
        expect(submission.items[1]['pickup'].size).to eq(2)
        expect(submission.items[1]['type']).to eq("recap")
      end

    end

  end

  context 'Submission with User Supplied Data' do
    describe 'Valid user Supplied Data' do
    end

    describe 'Invalid User Supplied Data' do
    end
  end

end
