require 'faraday'

module Requests::Submissions
  class Recap
    # include Requests::Gfa
    include Requests::Scsb

    attr_reader :submission, :service_type, :success_message

    def initialize(submission, service_type: 'recap')
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
      @service_type = service_type
      @success_message = I18n.t("requests.submit.#{service_type}_success", default: I18n.t('requests.submit.success'))
    end

    def handle
      items = submission.filter_items_by_service(service_type)
      items.each do |item|
        handle_item(item)
      end
    end

    def submitted
      @sent
    end

    attr_reader :errors

    private

      def handle_item(item)
        params = scsb_param_mapping(submission.bib, submission.patron, item)
        response = scsb_request(params)
        if response.status != 200
          error_message = "Request failed because #{response.body}"
          @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode, error: error_message }
        else
          response = parse_scsb_response(response)
          if response[:success] == false
            @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode, error: response[:screenMessage] }
          else
            @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode }
            handle_hold_for_item(item)
          end
        end
      end

      def handle_hold_for_item(item)
        return if submission.partner_item?(item) || submission.edd?(item)

        hold = Requests::Submissions::HoldItem.new(@submission, service_type: "recap")
        hold.handle_item(item: item)
        return if hold.errors.empty?
        hold.errors.map! do |error|
          reply_text = error["reply_text"]
          error.merge("reply_text" => "Recap request was successful, but creating the hold in Alma had an error: #{reply_text}")
        end
        Requests::RequestMailer.send("service_error_email", [hold], @submission).deliver_now
      end
  end
end
