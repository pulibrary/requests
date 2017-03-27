module Requests
  module Voyager
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def conn
      conn = Faraday.new(:url => Requests.config[:voyager_api_base]) do |faraday|
        faraday.request  :multipart             # allow XML data to be sent with request
        faraday.response :logger if !Rails.env.test?
        #faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn
    end

    def put_response(params, payload)
        request_url = "#{Requests.config[:voyager_api_base]}/vxws/record/#{params[:recordID]}/items/#{params[:itemID]}/recall?patron=#{params[:patron]}&patron_homedb=#{params[:patron_homedb]}&patron_group=#{params[:patron_group]}"
        conn.put request_url, payload, { 'X-Accept' => 'application/xml' }
    end

    def get_response(params)
        request_url = "#{Requests.config[:voyager_api_base]}/vxws/record/#{params['bib']['id']}/items/#{params['requestable'].first['item_id']}/recall?patron=#{params['request']['patron_id']}&patron_homedb=#{Requests.config[:voyager_ub_id]}&patron_group=#{params['request']['patron_group']}"
        conn.get request_url
    end

    # implement solr doc to Voyager schema mapping
    # each param should have an indifferent hash
    def param_mapping(bib, user, item)
      {
        recordID: bib['id'],
        itemID: item['item_id'],
        patron: user['patron_id'],
        patron_homedb: URI.escape(Requests.config[:voyager_ub_id]),
        patron_group: user['patron_group']
      }
    end

    def request_payload(item)
        pickup = item['pickup'].split("|")
        recall_request = Nokogiri::XML::Builder.new do |xml|
          xml.send(:"recall-parameters") {
            xml.send(:"pickup-location", pickup[0])
            xml.send(:"last-pickup-date", "20091006")
            xml.comment "testing recall request"
            xml.dbkey URI.escape(Requests.config[:voyager_ub_id])
          }
        end
        recall_request.to_xml
    end

  end
end
