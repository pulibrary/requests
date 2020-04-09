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

      return unless @xml_response.xpath("//recall/@allowed").text == 'N'
      error_message = @xml_response.xpath("//note").text
      @errors << { bibid: @params['bib']['id'], item: @params['requestable'].first['item_id'], patron: @params['request']['patron_id'], error: error_message }
      :A
    end

    def returned
      CobraVsMongoose.xml_to_hash(@xml_response.to_s).to_json
    end

    attr_reader :errors
  end
end
