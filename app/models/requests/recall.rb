require 'faraday'

module Requests
  class Recall

    include Requests::Voyager

    def initialize(submission)
      @submission = submission
      @errors = []
      @sent = []
      handle
    end

    def handle
      @submission.items.each do |item|
        params = param_mapping(@submission.bib, @submission.user, item)
        payload = request_payload(item)
        r = response(params, payload)
        xml_response  = Nokogiri::XML(r.body)
        unless xml_response.xpath("//reply-text").text() == 'ok'
            error_message =  "Failed request: " + xml_response.xpath("//note").text()
            @errors <<  { bibid: params[:recordID], item: params[:itemID], user_name: @submission.user[:user_name], patron: params[:patron], error: error_message }
        else
            @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], patron: params[:patron] }
        end
      end
    end

    def submitted?
        @sent
    end

    def errors
      @errors
    end

  end
end
