require 'faraday'
require 'cobravsmongoose'

module Requests
  class PickupLookup

    include Requests::Voyager

    def initialize(params)
      @params = params
      @errors = []
      @xml_response = {}
      handle
    end

    def handle
        r = get_response(@params)
        @xml_response = Nokogiri::XML(r.body)

        if @xml_response.xpath("//recall/@allowed").text() == 'N'
          error_message =  @xml_response.xpath("//note").text()
          @errors <<  { bibid: @params['bib']['id'], item: @params['requestable'].first['item_id'], patron: @params['request']['patron_id'], error: error_message }
        end

    end

    def returned
        hash = CobraVsMongoose.xml_to_hash(@xml_response.to_s).to_json
    end

    def errors
      @errors
    end

  end
end
