require 'faraday'

module Requests
  class Recall
    include Requests::Voyager
    include Requests::Scsb
    include Requests::Bibdata

    def initialize(submission)
      @service_type = 'recall'
      @submission = submission
      @errors = []
      @sent = []
      handle
    end

    def handle
      items = @submission.filter_items_by_service(@service_type)
      scsb_params = {}
      items.each do |item|
        location = get_location(item['location_code'])
        if (scsb_locations.include? item['location_code']) || (location[:library][:code] == 'recap')
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

      return false if scsb_params.empty?
      params = scsb_params
      # response = scsb_request(scsb_params)
      # if response.status != 200
      #   error_message = "Request failed because #{response.body}"
      #   @errors << { type: 'recall', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode], error: error_message }
      # else
      #   response = parse_scsb_response(response)
      #   if response[:success] == false
      #     @errors << { type: 'recall', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode], error: response[:screenMessage] }
      #   else
      @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode] }
      #   end
      # end
    end

    def submitted
      @sent
    end

    def errors
      @errors
    end
  end
end
