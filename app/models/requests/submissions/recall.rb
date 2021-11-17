require 'faraday'

module Requests::Submissions
  class Recall < Service
    include Requests::Voyager
    include Requests::Scsb
    include Requests::Bibdata

    def initialize(submission)
      super(submission, service_type: 'recall')
    end

    def handle
      items = @submission.filter_items_by_service(service_type)
      scsb_params = {}
      items.each do |item|
        scsb_params = handle_item(item: item, scsb_params: scsb_params)
      end

      return false if scsb_params.empty?
      params = scsb_params
      # response = scsb_request(scsb_params)
      # if response.status != 200
      #   error_message = "Request failed because #{response.body}"
      #   @errors << { type: 'recall', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.patron[:user_name], barcode: params[:patronBarcode], error: error_message }
      # else
      #   response = parse_scsb_response(response)
      #   if response[:success] == false
      #     @errors << { type: 'recall', bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.patron[:user_name], barcode: params[:patronBarcode], error: response[:screenMessage] }
      #   else
      @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: @submission.user_name, barcode: @submission.barcode }
      #   end
      # end
    end

    def send_mail
      Requests::RequestMailer.send("#{type}_email", self).deliver_now
      Requests::RequestMailer.send("scsb_recall_email", self).deliver_now if items_held_by_partner?
    end

    private

      def handle_item(item:, scsb_params:)
        # location = get_location(item['location_code'])
        if Requests::Config.recap_partner_location_codes.include? item['location_code'] # || (location[:library][:code] == 'recap')
          params = scsb_param_mapping(@submission.bib, @submission.patron, item)
          if scsb_params.empty?
            scsb_params = params
          else
            scsb_params[:itemBarcodes].push(item['barcode'])
          end
        else
          handle_non_scsb_recap_item(item: item)
        end
        scsb_params
      end

      def handle_non_scsb_recap_item(item:)
        params = param_mapping(@submission.bib, @submission.patron, item)
        payload = request_payload(item)
        r = put_response(params, payload)
        xml_response = Nokogiri::XML(r.body)
        if xml_response.xpath("//reply-text").text == 'ok'
          @sent << { bibid: params[:Bbid], item: params[:item], user_name: @submission.user_name, patron: params[:patron] }
        else
          error_message = "Failed request: " + xml_response.xpath("//note").text
          @errors << { bibid: params[:recordID], item: params[:itemID], user_name: @submission.user_name, patron: params[:patron], error: error_message }
        end
      end

      def items_held_by_partner?
        @items.select { |item| submission.partner_item?(item) }.size.positive?
      end
  end
end
