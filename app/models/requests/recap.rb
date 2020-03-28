require 'faraday'

module Requests
  class Recap
    # include Requests::Gfa
    include Requests::Scsb

    def initialize(submission)
      @service_type = 'recap'
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
      handle
    end

    def handle
      items = @submission.filter_items_by_service(@service_type)
      items.each do |item|
        ## Handle SCSB temporarily - eventually this will be how all items are handled
        # if scsb_locations.include? item['location_code']
        params = scsb_param_mapping(@submission.bib, @submission.user, item)
        response = scsb_request(params)
        if response.status != 200
          error_message = "Request failed because #{response.body}"
          @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode], error: error_message }
        else
          response = parse_scsb_response(response)
          if response[:success] == false
            @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode], error: response[:screenMessage] }
          else
            @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user[:user_name], barcode: params[:patronBarcode] }
          end
        end
      end
    end

    def submitted
      @sent
    end

    attr_reader :errors
  end
end
