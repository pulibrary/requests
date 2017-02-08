module Requests
  module Gfa
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def conn
      conn = Faraday.new(:url => Requests.config[:gfa_base]) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn
    end

    def response(params)
        conn.post "#{Requests.config[:gfa_base]}", params, { 'X-Accept' => 'application/xml' }
    end

    def parse_response(response)
      parsed = response.status == 201 ? parse_json(response.body) : {}
      parsed.class == Hash ? parsed.with_indifferent_access : parsed
    end

    # implement solr doc to GFA schema mapping
    # each param should an indifferent hash
    def param_mapping(bib, user, item)
      delivery_mode_key = "delivery_mode_#{item['item_id']}"
      delivery_mode = item[delivery_mode_key][0,1] #get first letter
      {
        Bbid: bib[:id],
        barcode: user[:user_barcode],
        item: item[:item_id],
        lname: user[:user_last_name],
        delivery: delivery_mode,
        pickup: item[:pickup],
        startpage: item[:edd_start_page],
        endpage: item[:edd_end_page],
        email: user[:email], #begin optional params
        volnum: item[:edd_volume_number],
        issue: item[:edd_issue],
        aauthor: item[:edd_author],
        atitle: item[:edd_art_title],
        note: item[:edd_note]
      }
    end

  end
end
