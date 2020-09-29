require 'spec_helper'

describe Requests::Submission do
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:user_info) do
    user = instance_double(User, guest?: false, uid: 'foo')
    Requests::Patron.new(user: user, session: {}, patron: valid_patron)
  end

  context 'A valid submission' do
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
          "type" => "recap",
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
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission) do
      described_class.new(params, user_info)
    end

    describe "contains" do
      it "no errors" do
        expect(submission.valid?).to be_truthy
        expect(submission.errors.full_messages.size).to eq(0)
      end

      it "a system ID" do
        expect(submission.id).to eq(bib[:id])
      end

      it "a user barcode" do
        expect(submission.user_barcode).to be_truthy
      end

      it "a user name" do
        expect(submission.user_name).to be_truthy
      end

      it "a user email address" do
        expect(submission.email).to be_truthy
      end

      it "one or more items requested attached. " do
        expect(submission.items).to be_truthy
        expect(submission.items).to be_an(Array)
        expect(submission.items.size).to be > 0
      end

      it "basic bibliographic information for a requested title" do
        expect(submission.bib['id']).to be_truthy
      end

      it "one service type" do
        expect(submission.service_types).to be_truthy
        expect(submission.service_types).to be_an(Array)
      end

      it 'does identify as a scsb partner item' do
        expect(submission.scsb?).to be false
      end
    end
  end

  context 'An invalid Submission' do
    let(:bib) do
      {
        "id" => ""
      }
    end

    let(:invalid_params) do
      {
        request: user_info,
        requestable: [{ "selected" => "true" }],
        bib: bib
      }
    end

    let(:invalid_submission) do
      described_class.new(invalid_params, user_info)
    end

    describe "invalid" do
      it 'includes error messsages' do
        expect(invalid_submission.valid?).to be_falsy
        expect(invalid_submission.errors.full_messages.size).to be > 0
      end
    end
  end

  context 'Recap' do
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
          "type" => "recap",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => "",
          "pickup" => "PA"
        },
        {
          "selected" => "true",
          "mfhd" => "534137",
          "call_number" => "HA202 .U581",
          "location_code" => "rcppa",
          "item_id" => "3059237",
          "delivery_mode_3059237" => "edd",
          "barcode" => "32101044283008",
          "enum" => "2000 (13th ed.)",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "edd_start_page" => "1",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => "",
          "pickup" => ""
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
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

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
        },
        {
          "type" => 'bd'
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
      described_class.new(params, user_info)
    end

    describe 'A valid Borrow Direct Direct Request' do
      it 'has a borrow direct eligible item selected' do
        expect(submission.items.first).to be_truthy
        expect(submission.items.first['type']).to eq('bd')
      end

      it 'has an auth_id' do
        expect(submission.bd['auth_id']).to eq(bd['auth_id'])
      end

      it 'has a pickup location' do
        expect(submission.items.first['pickup']).to eq(requestable.first['pickup'])
      end

      it 'has query parameters' do
        expect(submission.bd['query_params']).to eq(bd['query_params'])
      end
    end
  end

  context 'Recall' do
  end

  context 'Multiple Submission Types (Recap and Recall)' do
    let(:requestable) do
      [
        { "selected" => "true",
          "mfhd" => "538419",
          "call_number" => "GN670 .P74",
          "location_code" => "rcppa",
          "item_id" => "3710038",
          "barcode" => "32101091858066",
          "enum" => "vol. 5 (1896)",
          "copy_number" => "1",
          "status" => "Charged",
          "type" => "recall",
          "pickup" => "299|.Firestone Library Circulation Desk" },
        {
          "selected" => "true",
          "mfhd" => "538419",
          "call_number" => "GN670 .P74",
          "location_code" => "rcppa",
          "item_id" => "3707281",
          "barcode" => "32101091857142",
          "enum" => "vol. 4 (1895)",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_3707281" => "print",
          "pickup" => "PA",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        }
      ]
    end

    let(:bib) do
      {
        "id" => "495220",
        "title" => "Journal of the Polynesian Society.",
        "author" => "Polynesian Society (N.Z.)",
        "date" => "1892"
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
      described_class.new(params, user_info)
    end

    describe "Mixed Service Types" do
      it 'recall items have voyager pickup location code' do
        pickup = submission.items[0]['pickup'].split("|")

        expect(submission.items[0]['pickup']).to be_truthy
        expect(pickup[0].to_i.to_s).to eq(pickup[0])
        expect(submission.items[0]['type']).to eq("recall")
        expect(submission.patron.patron_id).to be_truthy
        expect(submission.patron.patron_group).to be_truthy
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

  context 'Invalid Submissions' do
    let(:bib) do
      {
        "id" => "495220",
        "title" => "Journal of the Polynesian Society.",
        "author" => "Polynesian Society (N.Z.)",
        "date" => "1892"
      }
    end
    describe 'An empty submission' do
      let(:requestable) { [] }
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end
      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end
      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'contains an error message' do
        expect(submission.errors.messages).to be_truthy
      end
    end

    describe 'A submission without a pickup location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "3059236",
            "barcode" => "32101044283008",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "annexa",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the item ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('3059236')).to be true
      end
    end

    describe 'A submission without a pickup location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "annexa",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('534137')).to be true
      end
    end

    describe 'A recall submission without a pickup location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Missing",
            "type" => "recall",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('534137')).to be true
        expect(submission.errors.messages[:items].first['534137']).to eq('text' => "Item Cannot be Recalled, see circulation desk.", 'type' => 'options')
      end
    end
    describe 'A recall submission without a pickup location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "12131313",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Missing",
            "type" => "recall",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the item ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('12131313')).to be true
      end
    end
    describe 'A borrow direct submission without a pickup location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Missing",
            "type" => "bd",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          },
          {
            'type' => 'bd'
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('534137')).to be true
      end
    end
    describe 'A bd submission without a pickup location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "12131313",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Missing",
            "type" => "bd",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the item ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('12131313')).to be true
      end
    end
    describe 'A recap submission without a pickup location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('534137')).to be true
      end
    end
    describe 'A recap submission without delivery type' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "121333",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap print submission without a pickup location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "121333",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "print",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap edd submission without start page' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "121333",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "edd",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap edd submission without a title' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "534137",
            "call_number" => "HA202 .U581",
            "location_code" => "rcppa",
            "item_id" => "121333",
            "barcode" => "",
            "enum" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "edd",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "1",
            "edd_end_page" => "40",
            "edd_volume_number" => "8",
            "edd_issue" => "30",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pickup" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable: requestable,
          bib: bib
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
  end

  describe 'A recap_no_items submission without a pickup location' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "4978217",
          "call_number" => "B52/140.fehb vol.7",
          "location_code" => "rcppl",
          "location" => "ReCAP - East Asian Library use only",
          "user_supplied_enum" => "test",
          "type" => "recap_no_items",
          "pickup" => ""
        },
        {
          "selected" => "false"
        }
      ]
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    before do
      submission.valid?
    end

    it 'is invalid' do
      expect(submission.valid?).to be false
    end

    it 'has an error message' do
      expect(submission.errors.messages).to be_truthy
    end

    it 'has an error message with the mfhd ID as the message key' do
      expect(submission.errors.messages[:items].first.keys.include?('4978217')).to be true
    end
  end

  describe 'Single Submission for a Print with SCSB Managed data' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "4222673",
          "call_number" => "708.9 B91",
          "location_code" => "scsbcul",
          "item_id" => "6348205",
          "barcode" => "CU13232533",
          "enum" => "",
          "copy_number" => "1",
          "status" => "Available",
          "cgc" => "",
          "cc" => "",
          "use_statement" => "",
          "type" => "recap",
          "delivery_mode_6348205" => "Physical Item Delivery",
          "pickup" => "QV",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
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
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission) do
      described_class.new(params, user_info)
    end

    before do
      submission.valid?
    end

    it 'Identifies as a SCSB partner item' do
      expect(submission.scsb?).to be true
    end
  end
end
