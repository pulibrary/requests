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
        begin
          status = place_hold(item)
        rescue Alma::BibRequest::ItemAlreadyExists => exists
          errors << { reply_text: "Can not create hold", create_hold: { note: "Hold already exists", message: exists.message } }.merge(@submission.bib.to_h).merge(item.to_h).with_indifferent_access
        rescue StandardError => invalid
          errors << { reply_text: "Can not create hold", create_hold: { note: "Hold can not be created", message: invalid.message } }.merge(@submission.bib.to_h).merge(item.to_h).with_indifferent_access
        end
        status
      end

      def place_hold(item)
        status = {}
        options = { mms_id: @submission.bib['id'], holding_id: item["mfhd"], item_pid: item['item_id'], user_id: @submission.patron.university_id, request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: item["pick_up_location_code"] }
        response = Requests::AlmaHoldRequest.submit(options)
        if response.success?
          status = item.merge(payload: options, response: response.raw_response.parsed_response)
        else
          errors << reponse_json["response"].merge(@submission.bib.to_h).merge(item.to_h).merge(type: @service_type)
        end
        status
      end
  end
end
