module Requests
  module Gfa
    # This class is no longer in use exempting it from code coverage
    extend ActiveSupport::Concern

    def conn
      conn = Faraday.new(:url => Requests.config[:gfa_base]) do |faraday|
        faraday.request  :url_encoded # form-encode POST params
        faraday.response :logger if !Rails.env.test? # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
      end
      conn
    end

    def response(params)
      conn.post "#{Requests.config[:gfa_base]}", params, { 'X-Accept' => 'application/xml' }
        # conn.get "#{Requests.config[:gfa_base]}", params
    end

    # implement solr doc to GFA schema mapping
    # each param should an indifferent hash
    def param_mapping(bib, user, item)
      delivery_mode_key = "delivery_mode_#{item['item_id']}"
      delivery_mode = item[delivery_mode_key][0, 1] # get first letter
      if delivery_mode == 'e'
        item[:pickup] = 'PA'
      end
      if item[:edd_start_page].blank?
        item[:edd_start_page] = '?'
      end
      {
        Bbid: bib[:id],
        barcode: user[:user_barcode],
        item: item[:item_id],
        lname: user[:user_last_name],
        delivery: delivery_mode,
        pickup: item[:pickup],
        startpage: item[:edd_start_page],
        endpage: item[:edd_end_page],
        email: user[:email], # begin optional params
        volnum: item[:edd_volume_number],
        issue: item[:edd_issue],
        aauthor: item[:edd_author],
        atitle: item[:edd_art_title],
        note: item[:edd_note]
      }
    end
  end
end