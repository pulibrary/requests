require 'faraday'

module Requests
  class Recap
    include Requests::Gfa
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
      scsb_params = {}
      items.each do |item|
        ## Handle SCSB temporarily - eventually this will be how all items are handled
        if scsb(item['location_code'])
          params = scsb_param_mapping(@submission.bib, @submission.user, item)
          if scsb_params.empty?
            scsb_params = params
          else
            scsb_params[:itemBarcodes].push(item['barcode'])
          end
        else
          params = param_mapping(@submission.bib, @submission.user, item)
          r = response(params)
          if r.status != 200
            @errors << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode], error: r.status }
          else
            xml_response = Nokogiri::XML(r.body)
            unless xml_response.xpath("//error").text().empty?
              error_message = "status " + r.status.to_s + ": " + xml_response.xpath("//error").text()
              @errors << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode], error: error_message }
            else
              @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user[:user_name], barcode: params[:barcode] }
            end
          end
        end
      end
      # return false unless scsb_params.empty?
      # response = scsb_request(scsb_params)
      # binding.pry
      # if response.status != 200
      #   @errors << { error: "error message" }
      # else
      #   @sent << { bibid: 'foo' }
      # end
    end

    def scsb(location_code)
      if scsb_locations.include?(location_code)
        true
      else
        false
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
