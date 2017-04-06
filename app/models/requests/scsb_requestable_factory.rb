module Requests
  class ScsbRequestableFactory

    include Requests::Scsb

    def initialize(holdings)
      @holdings = holdings
    end

    def items
       @items ||= build_items
    end    

    def build_items
      requestable_items = []
      ## scsb processing
      ## If mfhd present look for only that
      ## sort items by keys
      ## send query for availability by barcode
      ## overlay availability to the 'status' field
      ## make sure other fields map to the current data model for item in requestable
      ## adjust router to understand SCSB status
      holdings.each do |id, values|
        barcodes = values['items'].map { |e| e['barcode']  }
        barcodesort = {}
        values['items'].each {|item| barcodes ort[item['barcode']] = item }
        availability_data = items_by_barcode(barcodes)
        availability_data.each do |item|
          barcodesort[item['itemBarcode']]['status'] = item['itemAvailabilityStatus']
        end
        barcodesort.values.each do |item|
          params = build_requestable_params(
                {
                  item: item.with_indifferent_access,
                  holding: { "#{id.to_sym}" => holdings[id] },
                  location: locations[item_scsb_collection_group(item)]
                }
              )
          requestable_items << Requests::Requestable.new(params)
        end
      end
    end

    private
      def build_requestable_params(params)
        {
          bib: doc.with_indifferent_access,
          holding: params[:holding],
          item: params[:item],
          location: params[:location]
        }
      end
  end
end