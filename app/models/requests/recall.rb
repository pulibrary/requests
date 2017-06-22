require 'faraday'

module Requests
  class Recall
    include Requests::Voyager
    include Requests::Scsb

    def initialize(submission)
      @service_type = 'recall'
      @submission = submission
      @errors = []
      @sent = []
      handle
    end

    def handle
      # TODO: This needs to handle SCSB recalls
      items = @submission.filter_items_by_service(@service_type)
      scsb_params = {}
      items.each do |item|
        if scsb_locations.include? item['location_code']
          params = scsb_param_mapping(@submission.bib, @submission.user, item)
          if scsb_params.empty?
            scsb_params = params
          else
            scsb_params[:itemBarcodes].push(item['barcode'])
          end
        else
          params = param_mapping(@submission.bib, @submission.user, item)
          payload = request_payload(item)
          r = put_response(params, payload)
          xml_response = Nokogiri::XML(r.body)
          unless xml_response.xpath("//reply-text").text() == 'ok'
            error_message = "Failed request: " + xml_response.xpath("//note").text()
            @errors << { bibid: params[:recordID], item: params[:itemID], user_name: @submission.user[:user_name], patron: params[:patron], error: error_message }
          else
            @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], patron: params[:patron] }
          end
        end
      end
      # SCSB STuff
      return false if scsb_params.empty?
      params = scsb_params
      response = scsb_request(scsb_params)
      if response.status != 200
        @errors << { error: parse_scsb_response(response) }
      else
        @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode] }
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
