module Requests
  module Mapable
    extend ActiveSupport::Concern

    def map_url(mfhd_id)
      "#{Requests.config[:pulsearch_base]}/catalog/#{bib['id']}/stackmap?#{map_params(mfhd_id).to_query}"
    end

    private

      def map_params(mfhd_id)
        {
          cn: holding[mfhd_id]['call_number'],
          loc: location['code']
        }
      end
  end
end
