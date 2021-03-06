require 'faraday'

module Requests
  class HoldItem
    include Requests::Voyager

    def initialize(submission, service_type: 'on_shelf')
      @service_type = service_type
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

      def handle_item(item:)
        status = {}
        params = build_params(item: item)
        response_json = hold_status_data(params: params)
        if response_json["hold"].present? && response_json["hold"]["allowed"] == "Y"
          status = place_hold(item, params)
        elsif response_json["hold"].blank? || (response_json["hold"].present? && response_json["hold"]["note"] != "You have already placed a request for this item.")
          errors << { reply_text: "Can not create hold", create_hold: { note: "Hold can not be created" } }.merge(params["bib"].permit(params["bib"].keys)).merge(params["request"].to_h)
        end
        status
      end

      def build_params(item:)
        params = param_mapping(@submission.bib, @submission.patron, item)
        params["bib"] = @submission.bib
        params['requestable'] = @submission.items
        params['request'] = @submission.patron
        params
      end

      def hold_status_data(params:)
        response = get_hold_status(params)
        Hash.from_xml(response.body)["response"]
      end

      def place_hold(item, params)
        status = {}
        payload = request_payload(item, parameter_name: "hold-request-parameters", expiration_period: 7)
        response = put_hold_request(params, payload)
        reponse_json = Hash.from_xml(response.body)
        if reponse_json["response"]["reply_code"] == "0"
          status = item.merge(payload: payload)
        else
          bib = params["bib"]
          bib = bib.permit(params["bib"].keys) if bib.respond_to?(:permit)
          request = params["request"]
          request = request.permit(params["request"].keys) if request.respond_to?(:permit)
          errors << reponse_json["response"].merge(bib).merge(request.to_h).merge(type: @service_type)
        end
        status
      end
  end
end
