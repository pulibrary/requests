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

    # implement solr doc to GFA schema mapping
    # each param should an indifferent hash
    def param_mapping(bib, user, item)
      {
        Bbid: "foo",
        barcode: "bar"
      }
    end

  end
end