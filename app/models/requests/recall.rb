require 'faraday'

module Requests
  class Recall

    include Requests::Voyager

    def initialize(submission)
      @submission = submission
      @errors = []
      handle
    end

    def handle
      @submission.items.each do |item|
        params = param_mapping(@submission.bib, @submission.user, item)
        payload = request_payload(item)
        r = response(params, payload)
        binding.pry
        unless r.status == 201
            xml_response  = Nokogiri::XML(r.body)
            error_message = "status " + r.status.to_s + ": " + xml_response.xpath("//error").text()
            @errors <<  { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode], error: error_message }
        else
            @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode] }
        end
      end
    end

    def submitted?
      "foo"
    end

    def errors
      @errors
    end

  end
end
