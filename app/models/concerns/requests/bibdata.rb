module Requests
  module Bibdata
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern
    
    def solr_doc(system_id)
      response = Faraday.get "#{Requests.config[:pulsearch_base]}/catalog/#{system_id}.json"
      if (response = parse_response(response)).empty?
        response
      else
        response[:response][:document]
      end
    end

    def items_by_bib(system_id)
      response = bibdata_conn.get "/availability?id=#{system_id}"
      parse_response(response)
    end

    def items_by_mfhd(mfhd_id)
      response = bibdata_conn.get "/availability?mfhd=#{mfhd_id}"
      parse_response(response)
    end

    def get_location(location_code)
      response = bibdata_conn.get "/locations/holding_locations/#{location_code}.json"
      parse_response(response)
    end

    def get_pickups
      response = bibdata_conn.get "/locations/delivery_locations.json"
      parse_response(response)
    end

    def patron(patron_id)
      response = bibdata_conn.get "/patron/#{patron_id}"
      parse_response(response)
    end

    def bibdata_conn
      conn = Faraday.new(:url => Requests.config[:bibdata_base]) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn
    end

    def parse_response(response)
      parsed = response.status == 200 ? parse_json(response.body) : {}
      parsed.class == Hash ? parsed.with_indifferent_access : parsed
    end

    def parse_json(data)
      JSON.parse(data)
    end
    
  end
end