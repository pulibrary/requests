module Requests
  module Bibdata
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern
    
    def solr_doc(system_id)
      response = Faraday.get "#{Requests.config[:pulsearch_base]}/catalog/#{system_id}.json"
      response.body
    end

    def marc_record(system_id)
      response = bibdata_conn.get "/bibliographic/#{system_id}"
      response.body
    end

    def items(system_id)
      response = bibdata_conn.get "/bibliographic/#{system_id}/items"
      if response.status == 200
        response.body
      end
    end

    def items_by_mfhd(mfh_id)
      response = bibdata_conn.get "/holdings/#{mfh_id}/items"
      if response.status == 200
        response.body
      end
    end

    def location(location_code)
      response = bibdata_conn.get "/locations/holding_locations/#{location_code}.json"
      response.body
    end

    def patron(patron_id)
      response = bibdata_conn.get "/patron/#{patron_id}"
      response.body
    end

    def bibdata_conn
      conn = Faraday.new(:url => Requests.config[:bibdata_base]) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      conn
    end

    def parse_blacklight_solr_response(solr_response)
      solr_doc = parse_json(solr_response)
      solr_doc[:response][:document]
    end

    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end
    
  end
end