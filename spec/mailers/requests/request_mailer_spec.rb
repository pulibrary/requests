require 'spec_helper'
include Requests::ApplicationHelper

describe Requests::RequestMailer, :type => :mailer do

  context "send preservation email request" do
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
          "mfhd"=>"9533612",
          "call_number"=>"TR465 .C666 2016",
          "location_code"=>"pres",
          "item_id"=>"3059236",
          "barcode"=>"32101044283008",
          "copy_number"=>"0",
          "status"=>"Not Charged",
          "type"=>"pres",
          "pickup"=>"PA"
        }.with_indifferent_access,
        {
          "selected"=>"false",
        }.with_indifferent_access
      ]
    }
    let(:bib) {
      {
        "id"=>"9712355",
        "title"=>"The atlas of water damage on inkjet-printed fine art /",
        "author"=>"Connor, Meghan Burge, Daniel Rochester Institute of Technology"
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
      # expect(mail.to).to eq(["to@example.org"])
      # expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      # expect(mail.body.encoded).to match("Hi")
    end

  end

end
