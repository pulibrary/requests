module Requests
  class Requestable
    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_accessor :services

    include Requests::Pageable
    include Requests::Aeon
    include Requests::Illiad
    include Requests::Mapable

    def initialize(bib:, holding: nil, item: nil, location: nil)
      @bib ||= bib # hash of bibliographic data
      @holding ||= holding # hash of holding data
      @item ||= item # hash of item data
      @location ||= location # hash of location matrix data
    end

    ## If the item doesn't have any item level data use the holding mfhd ID as a unique key
    ## when one is needed. Primarily for non-barcoded Annex items.
    def preferred_request_id
      if item?
        item['id']
      else
        holding.first[0]
      end
    end

    def set_services service_list
      @services = service_list
    end

    # non voyager options
    def thesis?
      return false unless holding.key? "thesis"
      return true if holding["thesis"][:location_code] == 'mudd'
    end

    # Reading Room Request
    def aeon?
      return true if location[:aeon_location] == true
      unless item.nil?
        return true if item[:use_statement] == 'Supervised Use'
      end
    end

    # at an open location users may go to
    def open?
      return true if location[:open] == true
    end

    def recap?
      return false unless location_valid?
      return true if location[:library][:code] == 'recap'
    end

    def recap_edd?
      if scsb?
        return true if scsb_edd_cullection_codes.include? item[:collection_code]
        false
      else
        return true if location[:recap_electronic_delivery_location] == true
      end
    end

    def missing?
      return true if item[:status] == 'Missing'
    end

    def lewis?
      return true if ['sci', 'scith', 'sciref', 'sciefa'].include?(location[:code])
    end

    def plasma?
      return true if location[:code] == 'ppl'
    end

    def preservation?
      return true if location[:code] == 'pres'
    end

    # merge these two
    def annexa?
      return false unless location_valid?
      return true if location[:library][:code] == 'annexa'
    end

    # locations temporarily moved to annex should work
    def annexb?
      return false unless location_valid?
      return true if location[:library][:code] == 'annexb'
    end

    def circulates?
      return true if location[:circulates] == true
    end

    def always_requestable?
      return true if location[:always_requestable] == true
    end

    # Is the ReCAP Item from a partner location
    def scsb?
      return true if scsb_locations.include?(location['code'])
    end

    def use_restriction?
      return false if item.nil?
      return false unless scsb?
      return true unless item[:use_statement].nil?
    end

    def in_process?
      if item? && !scsb?
        if item[:status] == 'In Process' || item[:status] == 'On-Site - In Process'
          return true
        end
      end
    end

    def on_order?
      if item? && !scsb?
        if item[:status].starts_with?('On-Order') || item[:status].starts_with?('Pending Order')
          return true
        end
      end
    end

    def item?
      item
    end

    # FIXME
    def has_item_data?
      if item.nil?
        false
      else
        if item[:id].blank?
          false
        else
          true
        end
      end
    end

    def temp_loc?
      if item?
        if item[:temp_loc]
          true
        else
          false
        end
      end
    end

    def on_reserve?
      if item?
        if item[:on_reserve] == 'Y'
          true
        else
          false
        end
      end
    end

    def inaccessible?
      if item?
        if item[:status] == 'Inaccessible'
          true
        else
          false
        end
      end
    end

    def traceable?
      services.include?('trace') ? true : false
    end

    def pending?
      return false unless location_valid?
      return false unless on_order? || in_process? || preservation?
      if location[:library][:code] == 'recap' && location[:holding_library].blank?
        false
      else
        true
      end
    end

    def ill_eligible?
      services.include?('ill') ? true : false
    end

    def on_shelf?
      services.include?('on_shelf') ? true : false
    end

    def borrow_direct?
      services.include?('bd') ? true : false
    end

    def recallable?
      services.include?('recall') ? true : false
    end

    # assume numeric ids come from voyager
    def voyager_managed?
      return true if bib[:id].to_i > 0
    end

    def online?
      return false unless location_valid?
      return true if location[:library][:code] == 'online'
    end

    def urls
      if online? && bib['electronic_access_1display']
        JSON.parse(bib['electronic_access_1display'])
      else
        {}
      end
    end

    def charged?
      if item?
        if unavailable_statuses.include?(item[:status])
          true
        else
          if unavailable_statuses.include?(item[:scsb_status])
            true
          else
            nil
          end
        end
      end
    end

    def hold_request?
      if item?
        if item[:status] == 'Hold Request'
          true
        else
          false
        end
      else
        false
      end
    end

    def enumerated?
      if item?
        unless item[:enum].nil?
          true
        else
          false
        end
      else
        false
      end
    end

    def pageable?
      if charged?
        nil
      elsif !holding.first[1].key?('call_number_browse')
        nil
      elsif paging_locations.include? location['code']
        call_num = holding.first[1]['call_number_browse']
        if lc_number?(call_num)
          in_call_num_range(call_num, paging_ranges[location['code']])
        end
      end
    end

    def pageable_loc?
      if !holding.first[1].key?('call_number_browse')
        nil
      elsif paging_locations.include? location['code']
        call_num = holding.first[1]['call_number_browse']
        if lc_number?(call_num)
          in_call_num_range(call_num, paging_ranges[location['code']])
        end
      end
    end

    def pickup_locations
      if location[:delivery_locations].size > 0
        if scsb?
          scsb_pickup_override(item[:collection_code])
        else
          location[:delivery_locations]
        end
      end
    end

    # override the default delivery location for SCSB at certain collection codes
    def scsb_pickup_override collection_code
      if collection_code == 'AR'
        [Requests::BibdataService.delivery_locations[:PJ]]
      elsif collection_code == 'MR'
        [Requests::BibdataService.delivery_locations[:PK]]
      else
        location[:delivery_locations]
      end
    end

    def barcode?
      if item?
        if /^[0-9]+/.match(item[:barcode])
          true
        else
          false
        end
      else
        false
      end
    end

    def barcode
      item[:barcode]
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
