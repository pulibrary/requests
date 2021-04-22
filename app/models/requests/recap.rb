require 'faraday'

module Requests
  class Recap
    # include Requests::Gfa
    include Requests::Scsb

    def initialize(submission)
      @service_types = ['recap', 'recap_edd', 'recap_in_library', 'recap_marquand_in_library', 'recap_marquand_edd']
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
      handle
    end

    def handle
      service_types.each do |service_type|
        items = @submission.filter_items_by_service(service_type)
        items.each do |item|
          handle_item(item)
        end
      end
    end

    def submitted
      @sent
    end

    attr_reader :errors, :service_types

    private

      def handle_item(item)
        params = scsb_param_mapping(@submission.bib, @submission.patron, item)
        response = scsb_request(params)
        if response.status != 200
          error_message = "Request failed because #{response.body}"
          @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user_name, barcode: @submission.user_barcode, error: error_message }
        else
          response = parse_scsb_response(response)
          if response[:success] == false
            @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user_name, barcode: @submission.user_barcode, error: response[:screenMessage] }
          else
            @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user_name, barcode: @submission.user_barcode }
          end
        end
      end
  end
end
