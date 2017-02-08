module Requests
  module Mapable
    extend ActiveSupport::Concern

    def map_url
      "#{Requests.config[:stackmap_base]}?#{map_params.to_query}"
    end

    private

    def map_params
      {
        id: bib['id'],
        loc: holding.values.first['location_code']
      }
    end
  end
end