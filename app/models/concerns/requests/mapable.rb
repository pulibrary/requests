module Requests
  module Mapable
    extend ActiveSupport::Concern

    def map_link(bib, holding)
      "#{Requests.config[:stackmap_base]}?#{map_params(bib,holding).to_query}"
    end

    private

    def map_params(bib, holding)
      {
        id: bib['id'],
        loc: holding.values.first['location_code']
      }
    end
  end
end