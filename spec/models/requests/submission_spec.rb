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
          "pick_up" => "Firestone Library"
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
          "pick_up" => "PA"
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
          "pick_up" => ""
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
      it 'items have gfa pick-up location code' do
        expect(submission.items[0]['pick_up']).to be_truthy
        expect(submission.items[0]['pick_up']).to be_a(String)
        expect(submission.items[0]['pick_up'].size).to eq(2)
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
          "pick_up" => "Firestone Library"
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

      it 'has a pick-up location' do
        expect(submission.items.first['pick_up']).to eq(requestable.first['pick_up'])
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
          "pick_up" => "299|.Firestone Library Circulation Desk" },
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
          "pick_up" => "PA",
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
      it 'recall items have voyager pick-up location code' do
        pick_up = submission.items[0]['pick_up'].split("|")

        expect(submission.items[0]['pick_up']).to be_truthy
        expect(pick_up[0].to_i.to_s).to eq(pick_up[0])
        expect(submission.items[0]['type']).to eq("recall")
        expect(submission.patron.patron_id).to be_truthy
        expect(submission.patron.patron_group).to be_truthy
      end

      it 'recap items have gfa pick-up location code' do
        expect(submission.items[1]['pick_up']).to be_truthy
        expect(submission.items[1]['pick_up']).to be_a(String)
        expect(submission.items[1]['pick_up'].size).to eq(2)
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

    describe 'A submission without a pick-up location' do
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
            "pick_up" => ""
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

    describe 'A submission without a pick-up location and item ID' do
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
            "pick_up" => ""
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

    describe 'A recall submission without a pick-up location and item ID' do
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
            "pick_up" => ""
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
    describe 'A recall submission without a pick-up location' do
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
            "pick_up" => ""
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
    describe 'A borrow direct submission without a pick-up location and item ID' do
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
            "pick_up" => ""
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
    describe 'A bd submission without a pick-up location' do
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
            "pick_up" => ""
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
    describe 'A recap submission without a pick-up location and item ID' do
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
            "pick_up" => ""
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
            "pick_up" => ""
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
    describe 'A recap print submission without a pick-up location' do
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
            "pick_up" => ""
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
            "pick_up" => ""
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
            "pick_up" => ""
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

  describe 'A recap_no_items submission without a pick-up location' do
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
          "pick_up" => ""
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
          "pick_up" => "QV",
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

  context 'Clancy Item' do
    let(:requestable) do
      [
        { "selected" => "true", "bibid" => "5636487", "mfhd" => "5744248", "call_number" => "N7668.D6 J64 2008",
          "location_code" => "sa", "item_id" => "5214248", "barcode" => "32101072349515", "copy_number" => "1",
          "status" => "On-Site", "type" => "clancy_in_library", "fill_in" => "false",
          "delivery_mode_5214248" => "in_library", "pick_up" => "PA" }
      ]
    end

    let(:bib) { { "id" => "5636487", "title" => "Dogs : history, myth, art", "author" => "Johns, Catherine", "isbn" => "9780674030930" } }
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

    describe "#process_submission" do
      before do
        ENV['CLANCY_BASE_URL'] = "https://example.caiasoft.com/api"
      end

      it 'items contacts clancy and voyager' do
        voyager_url = stub_voyager_hold_success('5636487', '5214248', '99999')
        clancy_url = stub_clancy_post(barcode: "32101072349515")
        expect(submission).to be_valid
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:put, voyager_url)).to have_been_made
        expect(a_request(:post, clancy_url)).to have_been_made
      end

      it "returns hold errors" do
        voyager_url = stub_voyager_hold_failure('5636487', '5214248', '99999')
        clancy_url = "#{ENV['CLANCY_BASE_URL']}/circrequests/v1"
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:put, voyager_url)).to have_been_made
        expect(a_request(:post, clancy_url)).not_to have_been_made
        expect(submission.service_errors.first[:type]).to eq('clancy_hold')
      end

      it 'returns clancy errors' do
        voyager_url = stub_voyager_hold_success('5636487', '5214248', '99999')
        clancy_url = stub_clancy_post(barcode: "32101072349515", deny: 'Y', status: "Item Cannot be Retrieved - Item is Currently Circulating")
        expect(submission).to be_valid
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:put, voyager_url)).to have_been_made
        expect(a_request(:post, clancy_url)).to have_been_made
        expect(submission.service_errors.first[:type]).to eq('clancy')
      end
    end
  end

  context 'Clancy EDD Item' do
    let(:requestable) do
      [
        { "selected" => "true", "bibid" => "5636487", "mfhd" => "5744248", "call_number" => "N7668.D6 J64 2008",
          "location_code" => "sa", "item_id" => "5214248", "barcode" => "32101072349515", "copy_number" => "1",
          "status" => "On-Site", "type" => "clancy_edd", "fill_in" => "false",
          "delivery_mode_5214248" => "edd", "pick_up" => "PA", "edd_art_title" => "Test This is only a test", "edd_start_page" => "",
          "edd_end_page" => "", "edd_volume_number" => "", "edd_issue" => "", "edd_author" => "", "edd_note" => "This is a test",
          "edd_genre" => "book", "edd_location" => "Marquand Library", "edd_isbn" => "9782754101578", "edd_date" => "2008",
          "edd_publisher" => "Paris: Hazan", "edd_call_number" => "ND553.P6 D24 2008q", "edd_oclc_number" => "263300578", "edd_title" => "Picasso" }
      ]
    end

    let(:bib) { { "id" => "5636487", "title" => "Dogs : history, myth, art", "author" => "Johns, Catherine", "isbn" => "9780674030930" } }
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

    describe "#process_submission" do
      let(:patron_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/foo" }
      let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
      let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

      let(:responses) do
        {
          found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
          disavowed: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"DIS","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
          transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                              '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                              '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
          transaction_error: '{"Message":"The request is invalid."}',
          note_created: '{"Message":"An error occurred adding note to transaction 1093946"}'
        }
      end

      before do
        stub_request(:get, patron_url)
          .to_return(status: 200, body: responses[:found], headers: {})
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'items contacts illiad' do
        clancy_url = stub_clancy_post(barcode: "32101072349515")
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "foo", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine",
                                     "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Paris: Hazan", "ISSN" => "9780674030930", "CallNumber" => "ND553.P6 D24 2008q", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/5636487", "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy EDD", "AcceptNonEnglish" => true, "ESPNumber" => "263300578", "DocumentType" => "Book", "Location" => "Marquand Library", "PhotoArticleTitle" => "Test This is only a test"))
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url).to_return(status: 200, body: responses[:note_created], headers: {})
        expect(submission).to be_valid
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:get, patron_url)).to have_been_made
        expect(a_request(:post, transaction_url)).to have_been_made
        expect(a_request(:post, transaction_note_url)).to have_been_made
        expect(a_request(:post, clancy_url)).to have_been_made
      end
      # rubocop:enable RSpec/MultipleExpectations

      it "returns illiad errors" do
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "foo", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine",
                                     "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Paris: Hazan", "ISSN" => "9780674030930", "CallNumber" => "ND553.P6 D24 2008q", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/5636487", "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy EDD", "AcceptNonEnglish" => true, "ESPNumber" => "263300578", "DocumentType" => "Book", "Location" => "Marquand Library", "PhotoArticleTitle" => "Test This is only a test"))
          .to_return(status: 503, body: responses[:transaction_error], headers: {})
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:get, patron_url)).to have_been_made
        expect(a_request(:post, transaction_url)).to have_been_made
        expect(submission.service_errors.first[:type]).to eq('clancy_edd')
      end

      it "returns clancy errors" do
        clancy_url = stub_clancy_post(barcode: "32101072349515", deny: 'Y', status: "Item Cannot be Retrieved - Item is Currently Circulating")
        stub_request(:post, transaction_url).to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "foo", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => "09/09/2021", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine",
                                     "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Paris: Hazan", "ISSN" => "9780674030930", "CallNumber" => "ND553.P6 D24 2008q", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/5636487", "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy EDD", "AcceptNonEnglish" => true, "ESPNumber" => "263300578", "DocumentType" => "Book", "Location" => "Marquand Library", "PhotoArticleTitle" => "Test This is only a test"))
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url).to_return(status: 200, body: responses[:note_created], headers: {})
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:get, patron_url)).to have_been_made
        expect(a_request(:post, transaction_url)).to have_been_made
        expect(a_request(:post, clancy_url)).to have_been_made
        expect(submission.service_errors.first[:type]).to eq('clancy')
      end
    end
  end

  context 'Marquand non Clancy Item' do
    let(:requestable) do
      [
        { "selected" => "true", "bibid" => "5636487", "mfhd" => "5744248", "call_number" => "N7668.D6 J64 2008",
          "location_code" => "sa", "item_id" => "5214248", "barcode" => "32101072349515", "copy_number" => "1",
          "status" => "On-Site", "type" => "marquand_in_library", "fill_in" => "false",
          "delivery_mode_5214248" => "in_library", "pick_up" => "PA" }
      ]
    end

    let(:bib) { { "id" => "5636487", "title" => "Dogs : history, myth, art", "author" => "Johns, Catherine", "isbn" => "9780674030930" } }
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

    describe "#process_submission" do
      it 'items contacts voyager and emails marquand' do
        voyager_url = stub_voyager_hold_success('5636487', '5214248', '99999')
        expect(submission).to be_valid
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:put, voyager_url)).to have_been_made
      end

      it "returns hold errors" do
        voyager_url = stub_voyager_hold_failure('5636487', '5214248', '99999')
        clancy_url = "#{ENV['CLANCY_BASE_URL']}/circrequests/v1"
        expect { submission.process_submission }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(a_request(:put, voyager_url)).to have_been_made
        expect(a_request(:post, clancy_url)).not_to have_been_made
        expect(submission.service_errors.first[:type]).to eq('marquand_in_library')
      end
    end
  end
end
