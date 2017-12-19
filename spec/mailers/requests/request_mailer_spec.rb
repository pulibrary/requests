require 'spec_helper'
include Requests::ApplicationHelper

describe Requests::RequestMailer, :type => :mailer do
  let(:user_info) {
    {
      "user_name" => "Foo Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch" }
  }

  let(:guest_user_info) {
    {
      "user_name" => " Guest Request",
      "user_last_name" => " Guest Request",
      "user_barcode" => "ACCESS",
      "patron_id" => "",
      "patron_group" => "",
      "email" => "guest@foo.edu"
    }
  }

  before(:each) { stub_delivery_locations }

  context "send preservation email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_preservation) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("pres_email", submission_for_preservation).deliver_now
    }

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
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_preservation) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("pres_confirmation", submission_for_preservation).deliver_now
    }

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
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "10139326",
        "title" => "Abhath fi al-tasawwuf wa al-turuq al-sufiyah: al-zawayah wa al-marja'iyah al-diniyah..",
        "author" => "Jab al-Khayr, Sa'id"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_no_items) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("paging_email", submission_for_no_items).deliver_now
    }

    let(:sub) {
      pickups = []
      submission_for_no_items.items.each do |item|
        pickups.push(Requests::BibdataService.delivery_locations[item["pickup"]]["label"])
      end
      I18n.t('requests.paging.email_subject') + ' for ' + pickups.join(", ")
    }

    it "renders the headers" do
      expect(mail.subject).to eq(sub)
      expect(mail.to).to eq(["fstpage@princeton.edu"])
      expect(mail.cc).to eq(["wange@princeton.edu", submission_for_no_items.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.paging.email_conf_msg')
    end
  end

  context "send annexa email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "2286894",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_annexa) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("annexa_email", submission_for_annexa).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(mail.to).to eq(["ppllib@princeton.edu"])
      expect(mail.cc).to eq([submission_for_annexa.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.annexa.email_conf_msg')
    end
  end

  context "send anxadoc email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "6592589",
        "title" => "The Coast Guard's fiscal year 2007 budget request.",
        "author" => "United States"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_anxadoc) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("annexa_email", submission_for_anxadoc).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.annexa.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.anxadoc.email')])
      expect(mail.cc).to eq([submission_for_anxadoc.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.annexa.email_conf_msg')
    end
  end

  context "send annexb email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "10042951",
        "title" => "Agaricus of North America /",
        "author" => "Kerrigan, Richard Wade"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_annexb) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("annexb_email", submission_for_annexb).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.annexb.email_subject'))
      expect(mail.to).to eq(["lewislib@princeton.edu"])
      expect(mail.cc).to eq([submission_for_annexb.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.annexb.email_conf_msg')
    end
  end

  context "send on_order email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "10081566",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_on_order) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("on_order_email", submission_for_on_order).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.on_order.email_conf_msg')
    end
  end

  context "send on_order email patron confirmation" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "10081566",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_on_order) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("on_order_confirmation", submission_for_on_order).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([submission_for_on_order.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.on_order.patron_conf_msg')
    end
  end

  context "send in_process email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9646099",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_in_process) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("in_process_email", submission_for_in_process).deliver_now
    }

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
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9646099",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_in_process) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("in_process_confirmation", submission_for_in_process).deliver_now
    }

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
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "10005935",
        "title" => "The 21st century meeting and event technologies : powerful tools for better planning, marketing, and evaluation /",
        "author" => "Lee, Seungwon Boshnakova, Dessislava Goldblatt, Joe Jeff"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_trace) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("trace_email", submission_for_trace).deliver_now
    }

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
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9944355",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_recap) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("recap_email", submission_for_recap).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.recap.email_subject'))
      expect(mail.to).to eq(["foo@princeton.edu"])
      expect(mail.cc).to eq([submission_for_recap.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.recap.email_conf_msg')
    end
  end

  context "send recap email request for guest user" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "9944355",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: guest_user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_recap) {
      Requests::Submission.new(params)
    }

    let(:mail) {
      Requests::RequestMailer.send("recap_email", submission_for_recap).deliver_now
    }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.recap_guest.email_subject'))
      expect(mail.to).to eq([submission_for_recap.email])
      expect(mail.cc).to eq([I18n.t('requests.recap.guest_email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.recap_guest.email_conf_msg')
    end
  end

  context "send recall email request" do
    let(:requestable) {
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
    }
    let(:bib) {
      {
        "id" => "6883125",
        "title" => "Derrida : a very short introduction /",
        "author" => "Glendinning, Simon"
      }.with_indifferent_access
    }
    let(:params) {
      {
        request: user_info,
        requestable: requestable,
        bib: bib
      }
    }

    let(:submission_for_recall) {
      Requests::Submission.new(params)
    }

    let(:scsb_recall_mail) {
      Requests::RequestMailer.send("scsb_recall_email", submission_for_recall).deliver_now
    }

    let(:mail) {
      Requests::RequestMailer.send("recall_email", submission_for_recall).deliver_now
    }

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
end
