module Requests
  class Requestable
    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_accessor :services

    delegate :pageable_loc?, to: :@pageable
    delegate :map_url, to: :@mappable
    delegate :illiad_request_url, to: :@illiad

    include Requests::Aeon

    def initialize(bib:, holding: nil, item: nil, location: nil)
      @bib = bib # hash of bibliographic data
      @holding = holding # hash of holding data
      @item = item # hash of item data
      @location = location # hash of location matrix data
      @services = []
      @pageable = Pageable.new(call_number: holding.first[1]['call_number_browse'], location_code: location['code'])
      @mappable = Requests::Mapable.new(bib_id: bib[:id], holdings: holding, location_code: location[:code])
      @illiad = Requests::Illiad.new(enum: item&.fetch(:enum, nil), chron: item&.fetch(:chron, nil), call_number: holding.first[1]['call_number_browse'])
    end

    ## If the item doesn't have any item level data use the holding mfhd ID as a unique key
    ## when one is needed. Primarily for non-barcoded Annex items.
    def preferred_request_id
      if item? && item['id'].present?
        item['id']
      else
        holding.first[0]
      end
    end

    # non voyager options
    def thesis?
      return false unless holding.key? "thesis"
      holding["thesis"][:location_code] == 'mudd'
    end

    def numismatics?
      return false unless holding.key? "numismatics"
      holding["numismatics"][:location_code] == 'num'
    end

    # Reading Room Request
    def aeon?
      return true if location[:aeon_location] == true
      return false if item.nil?
      return true if item[:use_statement] == 'Supervised Use'
    end

    # at an open location users may go to
    def open?
      location[:open] == true
    end

    def recap?
      return false unless location_valid?
      location[:library][:code] == 'recap'
    end

    def recap_edd?
      (scsb? && scsb_edd_cullection_codes.include?(item[:collection_code])) ||
        ((location[:recap_electronic_delivery_location] == true) && !scsb?)
    end

    def missing?
      item[:status] == 'Missing'
    end

    def lewis?
      ['sci', 'scith', 'sciref', 'sciefa', 'sciss'].include?(location[:code])
    end

    def plasma?
      location[:code] == 'ppl'
    end

    def preservation?
      location[:code] == 'pres'
    end

    # merge these two
    def annexa?
      location_valid? && location[:library][:code] == 'annexa'
    end

    # locations temporarily moved to annex should work
    def annexb?
      location_valid? && location[:library][:code] == 'annexb'
    end

    def circulates?
      location[:circulates] == true && location[:library][:code] == "firestone"
    end

    def always_requestable?
      location[:always_requestable] == true
    end

    # Is the ReCAP Item from a partner location
    def scsb?
      scsb_locations.include?(location['code'])
    end

    def use_restriction?
      return false if item.nil?
      scsb? && item[:use_statement].present?
    end

    def in_process?
      return false unless item? && !scsb?
      item[:status] == 'In Process' || item[:status] == 'On-Site - In Process'
    end

    def on_order?
      return false unless item? && !scsb?
      item[:status].starts_with?('On-Order') || item[:status].starts_with?('Pending Order')
    end

    def item?
      item
    end

    def item_data?
      return false if item.nil?
      item[:id].present?
    end

    def temp_loc?
      return false unless item?
      item[:temp_loc].present?
    end

    def on_reserve?
      return false unless item?
      item[:on_reserve] == 'Y'
    end

    def inaccessible?
      return false unless item?
      item[:status] == 'Inaccessible'
    end

    def traceable?
      services.include?('trace')
    end

    def pending?
      return false unless location_valid?
      return false unless on_order? || in_process? || preservation?
      location[:library][:code] != 'recap' || location[:holding_library].present?
    end

    def ill_eligible?
      services.include?('ill')
    end

    def on_shelf?
      services.include?('on_shelf')
    end

    def on_shelf_edd?
      services.include?('on_shelf_edd')
    end

    def borrow_direct?
      services.include?('bd')
    end

    def recallable?
      services.include?('recall')
    end

    # assume numeric ids come from voyager
    def voyager_managed?
      bib[:id].to_i.positive?
    end

    def online?
      return false unless location_valid?
      location[:library][:code] == 'online'
    end

    def urls
      return {} unless online? && bib['electronic_access_1display']
      JSON.parse(bib['electronic_access_1display'])
    end

    def charged?
      return false unless item?
      unavailable_statuses.include?(item[:status]) || unavailable_statuses.include?(item[:scsb_status])
    end

    def hold_request?
      return false unless item?
      item[:status] == 'Hold Request'
    end

    def enumerated?
      return false unless item?
      item[:enum].present?
    end

    def pageable?
      return nill if charged?
      pageable_loc?
    end

    def pickup_locations
      return nil if location[:delivery_locations].empty?
      if scsb?
        scsb_pickup_override(item[:collection_code])
      else
        location[:delivery_locations]
      end
    end

    # override the default delivery location for SCSB at certain collection codes
    def scsb_pickup_override(collection_code)
      if collection_code == 'AR'
        [Requests::BibdataService.delivery_locations[:PJ]]
      elsif collection_code == 'MR'
        [Requests::BibdataService.delivery_locations[:PK]]
      else
        location[:delivery_locations]
      end
    end

    def scsb_in_library_use?
      return false unless item?
      scsb? && item[:use_statement] == "In Library Use"
    end

    def barcode?
      return false unless item?
      /^[0-9]+/.match(barcode).present?
    end

    def barcode
      item[:barcode]
    end

    def ask_me?
      services.include?('ask_me')
    end

    private

      def scsb_locations
        ['scsbnypl', 'scsbcul']
      end

      def unavailable_statuses
        ['Charged', 'Renewed', 'Overdue', 'On Hold', 'Hold Request', 'In transit',
         'In transit on hold', 'In Transit Discharged', 'In Transit On Hold', 'At bindery', 'Remote storage request',
         'Hold request', 'Recall request', 'Missing', 'Lost--Library Applied',
         'Lost--System Applied', 'Claims returned', 'Withdrawn', 'On-Site - Missing',
         'Missing', 'On-Site - On Hold', 'Inaccessible', 'Not Available', "Item Barcode doesn't exist in SCSB database."]
      end

      def scsb_edd_cullection_codes
        %w[AR BR CA CH CJ CP CR CU EN EV GC GE GS HS JC JD LD LE ML SW UT NA NH NL NP NQ NS NW GN JN JO PA PB PN GP JP]
      end

      def location_valid?
        location.key?(:library) && location[:library].key?(:code)
      end
  end
end
