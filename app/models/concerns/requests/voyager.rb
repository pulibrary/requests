module Requests
  module Voyager
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def conn
      conn = Faraday.new(:url => Requests.config[:voyager_api_base]) do |faraday|
        faraday.request  :multipart             # allow XML data to be sent with request
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn
    end

    def response(params, payload)
        request_url = "#{Requests.config[:voyager_api_base]}/vxws/record/#{params[:recordID]}/items/#{params[:itemID]}/recall?patron=#{params[:patron]}&patron_homedb=#{params[:patron_homedb]}&patron_group=#{params[:patron_group]}"
        conn.put request_url, payload, { 'X-Accept' => 'application/xml' }
    end

    # implement solr doc to Voyager schema mapping
    # each param should have an indifferent hash
    def param_mapping(bib, user, item)
      {
        recordID: bib[:id],
        itemID: item[:item_id],
        patron: user[:patron_id],
        #patron_homedb: Requests.config[:voyager_ub_id], #need to reconcile requests.yml with orangelight coming back as 1@DB
        patron_homedb: '1@PRINCETONDB20050302104001',
        patron_group: user[:patron_group]
      }
    end

    def request_payload(item)
        recall_request = Nokogiri::XML::Builder.new do |xml|
          xml.send(:"recall-parameters") {
            xml.send(:"pickup-location", item[:pickup])
            xml.send(:"last-pickup-date", "20091006")
            xml.comment "testing recall request"
            xml.dbkey "1@PRINCETONDB20050302104001"
          }
        end
        recall_request.to_xml
    end

  end
end
