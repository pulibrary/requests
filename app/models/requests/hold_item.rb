require 'faraday'

module Requests
  class HoldItem
    include Requests::Voyager

    def initialize(submission)
      @service_type = 'on_shelf'
      @submission = submission
      @errors = []
      @sent = []
      handle
    end

    def handle
      items = @submission.filter_items_by_service(@service_type)
      status = {}
      items.each do |item|
        status = handle_item(item: item)
      end

      return false if status.empty?
      params = status
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

    attr_reader :errors

    private

      def handle_item(item:)
        status = {}
        params = build_params(item: item)
        if can_place_hold(params: params)
          payload = request_payload(item, parameter_name: "hold-request-parameters")
          response = put_hold_request(params, payload)
          reponse_json = Hash.from_xml(response.body)
          if reponse_json["response"]["reply_code"] == "0"
            status = params
          else
            errors << reponse_json["response"]
          end

        end
        status
      end

      def build_params(item:)
        params = param_mapping(@submission.bib, @submission.user, item)
        params["bib"] = @submission.bib
        params['requestable'] = @submission.items
        params['request'] = @submission.user
        params
      end

      def can_place_hold(params:)
        response = get_hold_status(params)
        reponse_json = Hash.from_xml(response.body)
        reponse_json["response"]["hold"].present? && reponse_json["response"]["hold"]["allowed"] == "Y"
      end
  end
end

# https://webvoyage.princeton.edu:7014/vxws/record/4815239/items/7448875/hold?patron=12345&patron_homedb=1@PRINCETONDB20050302104001
# https://webvoyage.princeton.edu:7014/vxws/record/11451836/items/8183358/hold?patron=95215&patron_homedb=1@PRINCETONDB20050302104001
