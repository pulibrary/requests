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
      items.each do |item|
        item_status = handle_item(item: item)
        @sent << item_status unless item_status.blank?
      end
      return false if @errors.present?
    end

    def submitted
      @sent
    end

    attr_reader :errors

    private

      # rubocop:disable Metrics/MethodLength
      def handle_item(item:)
        status = {}
        params = build_params(item: item)
        response_json = hold_status_data(params: params)
        if response_json["hold"].present? && response_json["hold"]["note"] == "Could not retrieve items for request."
          params.delete(:itemID)
          response_json = hold_status_data(params: params)
        end
        if response_json["hold"].present? && response_json["hold"]["allowed"] == "Y"
          status = place_hold(item, params)
        elsif response_json["hold"].blank?
          errors << { reply_text: "Can not create hold", create_hold: { note: "Hold can not be created" } }.merge(safe_permit(params["bib"])).merge(safe_permit(params["request"]))
        elsif response_json["hold"].present? && response_json["hold"]["note"] != "You have already placed a request for this item."
          errors << response_json["hold"].merge(safe_permit(params["bib"])).merge(safe_permit(params["request"]))
        end
        status
      end
      # rubocop:enable Metrics/MethodLength

      def build_params(item:)
        params = param_mapping(@submission.bib, @submission.user, item)
        params["bib"] = @submission.bib
        params['requestable'] = @submission.items
        params['request'] = @submission.user
        params
      end

      def hold_status_data(params:)
        response = get_hold_status(params)
        Hash.from_xml(response.body)["response"]
      end

      def place_hold(item, params)
        status = {}
        payload = payload(item, params)
        response = put_hold_request(params, payload)
        reponse_json = Hash.from_xml(response.body)
        if reponse_json["response"]["reply_code"] == "0"
          status = item.merge(payload: payload)
        else
          errors << reponse_json["response"].merge(safe_permit(params["bib"])).merge(safe_permit(params["request"]))
        end
        status
      end

      def safe_permit(hash)
        if hash.respond_to?(:permit)
          hash.permit(hash.keys)
        else
          hash
        end
      end

      def payload(item, params)
        parameter_name = if params.keys.include?(:itemID)
                           "hold-request-parameters"
                         else
                           "hold-title-parameters"
                         end
        request_payload(item, parameter_name: parameter_name, expiration_period: 7)
      end
  end
end

# https://webvoyage.princeton.edu:7014/vxws/record/4815239/items/7448875/hold?patron=12345&patron_homedb=1@PRINCETONDB20050302104001
# https://webvoyage.princeton.edu:7014/vxws/record/11451836/items/8183358/hold?patron=95215&patron_homedb=1@PRINCETONDB20050302104001
