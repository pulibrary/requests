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

    # non longer used pickups loaded in requests initializer to avoid repeat calls
    # def get_pickups
    #   response = bibdata_conn.get "/locations/delivery_locations.json"
    #   parse_response(response)
    # end

    def patron(patron_id)
      response = bibdata_conn.get "/patron/#{patron_id}"
      parse_response(response)
    end

    def bibdata_conn
      conn = Faraday.new(:url => Requests.config[:bibdata_base]) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        #faraday.response :logger                  # log requests to STDOUT
        faraday.response :logger if !Rails.env.test?
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

    ## Accepts an array of location hashes and sorts them according to our quirks
    def sort_pickups locs
      #staff only locations go at the bottom of the list and Firestone to the top
      locs.sort_by! { |loc| loc[:staff_only] ? 0 : 1 }
      locs.each do |loc|
        if loc[:staff_only]
          loc[:label] = loc[:label] + " (staff only)"
        end
      end
      locs.reverse!
      firestone = locs.find {|loc| loc[:label] == "Firestone Library" }
      unless firestone.nil?
        locs.insert(0,locs.delete_at(locs.index(firestone)))
      end
      locs
    end

  end
end
