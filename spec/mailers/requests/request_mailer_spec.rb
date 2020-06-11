require 'spec_helper'
include Requests::ApplicationHelper

# rubocop:disable RSpec/MultipleExpectations
describe Requests::RequestMailer, type: :mailer, vcr: { cassette_name: 'mailer', record: :new_episodes } do
  let(:user_info) do
    {
      "user_name" => "Foo Request",
      "user_last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
  end

  let(:guest_user_info) do
    {
      "user_name" => " Guest Request",
      "user_last_name" => " Guest Request",
      "user_barcode" => "ACCESS",
      "patron_id" => "",
      "patron_group" => "",
      "email" => "guest@foo.edu"
    }
  end

  before { stub_delivery_locations }

  context "send preservation email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_preservation) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("pres_email", submission_for_preservation).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.pres.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.pres.email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.pres.email_conf_msg')
    end
  end

  context "send preservation email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_preservation) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("pres_confirmation", submission_for_preservation).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.pres.email_subject'))
      expect(mail.to).to eq([submission_for_preservation.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.pres.patron_conf_msg')
    end
  end

  context "send page record with no_items email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9929080",
          "location_code" => "rcppa",
          "item_id" => "10139326",
          "status" => "Not Charged",
          "type" => "paging",
          "pickup" => "PN"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10139326",
        "title" => "Abhath fi al-tasawwuf wa al-turuq al-sufiyah: al-zawayah wa al-marja'iyah al-diniyah..",
        "author" => "Jab al-Khayr, Sa'id"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_no_items) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("paging_email", submission_for_no_items).deliver_now
    end

    let(:confirmation) do
      Requests::RequestMailer.send("paging_confirmation", submission_for_no_items).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Paging Request for Lewis Library")
      expect(mail.to).to eq(["fstpage@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.paging.email_conf_msg')
    end

    it "renders the confirmation" do
      expect(confirmation.subject).to eq("Paging Request for Lewis Library")
      expect(confirmation.to).to eq([submission_for_no_items.email])
      expect(confirmation.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation.body.encoded).to have_content(I18n.t('requests.paging.email_conf_msg'))
      expect(confirmation.body.encoded).to have_content('Wear a mask or face covering')
    end
  end

  context "send annexa email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2576882",
          "call_number" => "Oversize HQ766 .B53f",
          "location_code" => "l",
          "item_id" => "2286894",
          "status" => "Not Charged",
          "type" => "annexa",
          "pickup" => "PQ"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "2286894",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_annexa) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("annexa_email", submission_for_annexa).deliver_now
    end

    let(:confirmation_mail) do
      Requests::RequestMailer.send("annexa_confirmation", submission_for_annexa).deliver_now
    end

    it "renders email to library staffs" do
      expect(mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.annexa.email')])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.annexa.email_conf_msg')
    end

    it "renders email confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_annexa.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
      expect(confirmation_mail.html_part.body.to_s).to have_content('Wear a mask or face covering')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content('Wear a mask or face covering')
    end
  end

  context "send anxadoc email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "6549667",
          "call_number" => "Y 4.C 73/7:S.HRG.109-1132",
          "location_code" => "anxadoc",
          "item_id" => "6068846",
          "status" => "Not Charged",
          "type" => "annexa",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "6592589",
        "title" => "The Coast Guard's fiscal year 2007 budget request.",
        "author" => "United States"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_anxadoc) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("annexa_email", submission_for_anxadoc).deliver_now
    end

    let(:confirmation_mail) do
      Requests::RequestMailer.send("annexa_confirmation", submission_for_anxadoc).deliver_now
    end

    it "renders and email to the librarians" do
      expect(mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.anxadoc.email')])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
    end

    it "renders a confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_anxadoc.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
      expect(confirmation_mail.html_part.body.to_s).to have_content('Wear a mask or face covering')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annexa.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content('Wear a mask or face covering')
    end
  end

  context "send annexb email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9840542",
          "call_number" => "QK629.A4 K45 2016",
          "location_code" => "anxb",
          "item_id" => "7528249",
          "barcode" => "32101095859144",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "annexb",
          "pickup" => "PN"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10042951",
        "title" => "Agaricus of North America /",
        "author" => "Kerrigan, Richard Wade"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_annexb) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("annexb_email", submission_for_annexb).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.annexb.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.annexb.email')])
      expect(mail.cc).to eq([submission_for_annexb.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.annexb.email_conf_msg')
    end
  end

  context "send on_order email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9878235",
          "location_code" => "j",
          "item_id" => "10081566",
          "status" => "On-Order",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10081566",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_on_order) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("on_order_email", submission_for_on_order).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_order.email_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_order.email_conf_msg')
    end
  end

  context "send on_order email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9878235",
          "location_code" => "j",
          "item_id" => "10081566",
          "status" => "On-Order",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10081566",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_on_order) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("on_order_confirmation", submission_for_on_order).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([submission_for_on_order.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_order.patron_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_order.patron_conf_msg')
    end
  end

  context "send in_process email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9479064",
          "call_number" => "PQ8098.429.E58 C37 2015",
          "location_code" => "f",
          "item_id" => "7384386",
          "barcode" => "32101098590092",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "in_process"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9646099",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_in_process) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("in_process_email", submission_for_in_process).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.in_process.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.in_process.email_conf_msg')
    end
  end

  context "send in_process email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9479064",
          "call_number" => "PQ8098.429.E58 C37 2015",
          "location_code" => "f",
          "item_id" => "7384386",
          "barcode" => "32101098590092",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "in_process"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9646099",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_in_process) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("in_process_confirmation", submission_for_in_process).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.in_process.email_subject'))
      expect(mail.to).to eq([submission_for_in_process.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.in_process.patron_conf_msg')
    end
  end

  context "send trace email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9810292",
          "call_number" => "GT3405 .L44 2017",
          "location_code" => "f",
          "item_id" => "7499956",
          "barcode" => "32101095686430",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "trace"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10005935",
        "title" => "The 21st century meeting and event technologies : powerful tools for better planning, marketing, and evaluation /",
        "author" => "Lee, Seungwon Boshnakova, Dessislava Goldblatt, Joe Jeff"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_trace) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("trace_email", submission_for_trace).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.trace.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.cc).to eq([submission_for_trace.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.trace.email_conf_msg')
    end
  end

  context "send recap email request for authenticated user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9757511",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "rcppa",
          "item_id" => "7467161",
          "barcode" => "32101098722844",
          "enum" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pickup" => "PA",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9944355",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("recap_email", submission_for_recap).deliver_now
    end

    let(:confirmation_mail) do
      Requests::RequestMailer.send("recap_confirmation", submission_for_recap).deliver_now
    end

    it "sens no email for a registered user" do
      expect(mail).to be_nil
    end

    it "renders the confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.recap.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_recap.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.recap.email_conf_msg')
      expect(confirmation_mail.html_part.body.to_s).to have_content('Wear a mask or face covering')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.recap.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content('Wear a mask or face covering')
    end
  end

  context "send recap edd confirmation request for authenticated user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9757511",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "rcppa",
          "item_id" => "7467161",
          "barcode" => "32101098722844",
          "enum" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pickup" => "PA",
          "edd_start_page" => "1",
          "edd_end_page" => "20",
          "edd_volume_number" => "4",
          "edd_issue" => "1",
          "edd_author" => "author",
          "edd_art_title" => "title",
          "edd_note" => "note"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9944355",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("recap_edd_confirmation", submission_for_recap).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.recap_edd.email_subject'))
      expect(mail.to).to eq([submission_for_recap.email])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.recap_edd.email_conf_msg')
      expect(mail.html_part.body.to_s).not_to have_content('Wear a mask or face covering')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.recap_edd.email_conf_msg')
      expect(mail.text_part.body.to_s).not_to have_content('Wear a mask or face covering')
    end
  end

  context "send recap email request for guest user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9757511",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "rcppa",
          "item_id" => "7467161",
          "barcode" => "32101098722844",
          "enum" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pickup" => "PA",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9944355",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: guest_user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("recap_email", submission_for_recap).deliver_now
    end

    let(:confirmation_mail) do
      Requests::RequestMailer.send("recap_confirmation", submission_for_recap).deliver_now
    end

    it "renders the email to the library" do
      expect(mail.subject).to eq(I18n.t('requests.recap_guest.email_subject'))
      expect(mail.cc).to be_nil
      expect(mail.to).to eq([I18n.t('requests.recap.guest_email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.html_part.body.to_s).not_to have_content I18n.t('requests.recap_guest.email_conf_msg')
      expect(mail.text_part.body.to_s).not_to have_content I18n.t('requests.recap_guest.email_conf_msg')
    end

    it "renders the confirmation email" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.recap_guest.email_subject'))
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.to).to eq([submission_for_recap.email])
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.recap_guest.email_conf_msg')
      expect(confirmation_mail.html_part.body.to_s).to have_content('Wear a mask or face covering')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.recap_guest.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content('Wear a mask or face covering')
    end
  end

  context "send recall email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "6794304",
          "call_number" => "B2430.D484 G54 2011",
          "location_code" => "f",
          "item_id" => "6195366",
          "barcode" => "32101081296699",
          "copy_number" => "1",
          "status" => "Renewed",
          "type" => "recall",
          "pickup" => "299|.Firestone Library Circulation Desk"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "6883125",
        "title" => "Derrida : a very short introduction /",
        "author" => "Glendinning, Simon"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_recall) do
      Requests::Submission.new(params)
    end

    let(:scsb_recall_mail) do
      Requests::RequestMailer.send("scsb_recall_email", submission_for_recall).deliver_now
    end

    let(:mail) do
      Requests::RequestMailer.send("recall_email", submission_for_recall).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.recall.email_subject'))
      expect(mail.to).to eq(['foo@princeton.edu'])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.recall.email_conf_msg')
    end

    it "renders the headers for a staff email" do
      expect(scsb_recall_mail.subject).to eq(I18n.t('requests.recall.staff_email_subject'))
      expect(scsb_recall_mail.to).to eq([I18n.t('requests.recap.scsb_recall_destination')])
      expect(scsb_recall_mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body for a staff email" do
      expect(scsb_recall_mail.body.encoded).to have_content I18n.t('requests.recall.staff_conf_msg')
    end
  end

  context "send plasma email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "10066344",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "ppl",
          "item_id" => "7659317",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "ppl",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10292269",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_ppl) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("ppl_email", submission_for_ppl).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.ppl.email_subject'))
      expect(mail.to).to eq(["ppllib@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.ppl.email_conf_msg')
    end
  end

  context "send plasma email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "10066344",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "ppl",
          "item_id" => "7659317",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "ppl",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10292269",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_plasma) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("ppl_confirmation", submission_for_plasma).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.ppl.email_subject'))
      expect(mail.to).to eq([submission_for_plasma.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.ppl.email_conf_msg')
    end
  end
  context "send lewis email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "10066344",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "sci",
          "item_id" => "7659317",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "lewis",
          "pickup" => "PN"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10292269",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_lewis) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("lewis_email", submission_for_lewis).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.lewis.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.lewis.email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.lewis.email_conf_msg')
    end
  end

  context "send lewis email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "10066344",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "sci",
          "item_id" => "7659317",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "lewis",
          "pickup" => "PN"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10292269",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_lewis) do
      Requests::Submission.new(params)
    end

    let(:mail) do
      Requests::RequestMailer.send("lewis_confirmation", submission_for_lewis).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.lewis.email_subject'))
      expect(mail.to).to eq([submission_for_lewis.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.lewis.email_conf_msg')
    end
  end

  context "Item on shelf in firestone" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9092827",
          "call_number" => "PS3566.I428 A6 2015",
          "location_code" => "f",
          "item_id" => "7267874",
          "barcode" => "32101096297443",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "on_shelf",
          "pickup" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9222024",
        "title" => "This angel on my chest : stories",
        "author" => "Pietrzyk, Leslie"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_on_shelf) do
      Requests::Submission.new(params)
    end
    # rubocop:disable RSpec/ExampleLength
    it "sends the email and renders the headers and body" do
      mail = Requests::RequestMailer.send("on_shelf_email", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("#{I18n.t('requests.on_shelf.email_subject')} (F) PS3566.I428 A6 2015")
      expect(mail.to).to eq([I18n.t('requests.on_shelf.email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end

    it "sends the confirmation email and renders the headers and body" do
      mail = Requests::RequestMailer.send("on_shelf_confirmation", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("Firestone Library #{I18n.t('requests.on_shelf.email_subject_patron')}")
      expect(mail.to).to eq([submission_for_on_shelf.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "Item on shelf in East Asian" do
    let(:requestable) do
      [
        { "selected" => "true",
          "mfhd" => "3892744",
          "call_number" => "PL2727.S2 C574 1998",
          "location_code" => "c",
          "item_id" => "3020750",
          "barcode" => "32101042398345",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "on_shelf",
          "pickup" => "PL" }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "3573258",
        "title" => "Hong lou fang zhen : Da guan yuan zai Gong wang fu 红楼访真　: 大观园在恭王府　",
        "author" => "Zhou, Ruchang"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    end

    let(:submission_for_on_shelf) do
      Requests::Submission.new(params)
    end

    # rubocop:disable RSpec/ExampleLength
    it "sends the email and renders the headers and body" do
      mail = Requests::RequestMailer.send("on_shelf_email", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("#{I18n.t('requests.on_shelf.email_subject')} (C) PL2727.S2 C574 1998")
      expect(mail.to).to eq(["gestcirc@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "sends the confirmation email and renders the headers and body" do
      mail = Requests::RequestMailer.send("on_shelf_confirmation", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("East Asian Library #{I18n.t('requests.on_shelf.email_subject_patron')}")
      expect(mail.to).to eq([submission_for_on_shelf.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_shelf.email_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
# rubocop:enable RSpec/MultipleExpectations
