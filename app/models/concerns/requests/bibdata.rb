module Requests
  module Bibdata
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def solr_doc(system_id)
      response = Faraday.get "#{Requests.config[:pulsearch_base]}/catalog/#{system_id}/raw"
      parse_response(response)
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

    def patron(patron_id)
      response = bibdata_conn.get "/patron/#{patron_id}"
      parse_response(response)
    end

    def bibdata_conn
      conn = Faraday.new(:url => Requests.config[:bibdata_base]) do |faraday|
        faraday.request  :url_encoded # form-encode POST params
        # faraday.response :logger                  # log requests to STDOUT
        faraday.response :logger if !Rails.env.test?
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
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
      # staff only locations go at the bottom of the list and Firestone to the top

      public_locs = locs.select { |loc| loc[:staff_only] == false }
      public_locs.sort_by! { |loc| loc[:label] }

      firestone = public_locs.find { |loc| loc[:label] == "Firestone Library" }
      unless firestone.nil?
        public_locs.insert(0, public_locs.delete_at(public_locs.index(firestone)))
      end

      staff_locs = locs.select { |loc| loc[:staff_only] == true }
      staff_locs.sort_by! { |loc| loc[:label] }

      staff_locs.each do |loc|
        loc[:label] = loc[:label] + " (Staff Only)"
      end
      public_locs + staff_locs
    end
  end
end
