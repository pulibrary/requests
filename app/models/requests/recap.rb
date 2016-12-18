require 'faraday'

module Requests
  class Recap

    include Requests::Gfa

    def initialize(submission)
      @submission = submission
      @sent = [] #array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] #array of hashes with bibid and item_id and error message
      handle
    end

    def handle
      @submission.items.each do |item|
        params = param_mapping(@submission.bib, @submission.user, item)
        r = response(params)
        unless r.status == 201
            xml_response  = Nokogiri::XML(r.body)
            error_message = "status " + r.status.to_s + ": " + xml_response.xpath("//error").text()
            @errors <<  { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode], error: error_message }
        else
            @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode] }
        end
      end

    end

    def submitted
      @sent
    end

    def errors
      @errors
    end

  end
end
