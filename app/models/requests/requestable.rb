module Requests
  class Requestable
    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_reader :call_number
    attr_reader :title
    attr_reader :user_barcode
    attr_reader :etas_limited_access
    attr_accessor :services

    delegate :pageable_loc?, to: :@pageable
    delegate :map_url, to: :@mappable
    delegate :illiad_request_url, :illiad_request_parameters, to: :@illiad

    include Requests::Aeon

    def initialize(bib:, holding: nil, item: nil, location: nil, user_barcode:)
      @bib = bib # hash of bibliographic data
      @holding = holding # hash of holding data
      @item = item # hash of item data
      @location = location # hash of location matrix data
      @services = []
      @user_barcode = user_barcode
      @call_number = holding.first[1]['call_number_browse']
      @etas_limited_access = holding.first[1]["etas_limited_access"]
      @title = bib[:title_citation_display]&.first
      @pageable = Pageable.new(call_number: call_number, location_code: location_code)
      @mappable = Requests::Mapable.new(bib_id: bib[:id], holdings: holding, location_code: location_code)
      @illiad = Requests::Illiad.new(enum: item&.fetch(:enum, nil), chron: item&.fetch(:chron, nil), call_number: holding.first[1]['call_number_browse'])
    end

    def digitize?
      (item_data? || !circulates?) && (on_shelf_edd? || recap_edd?) && !request_status?
    end

    def fill_in_digitize?
      !item_data? || digitize?
    end

    def pick_up?
      return false if user_barcode.blank? || etas?
      item_data? && (on_shelf? || recap? || annexa?) && circulates? && !in_library_use_only? && !request?
    end

    def fill_in_pickup?
      return false if user_barcode.blank?
      !item_data? || pick_up?
    end

    def request?
      return false if user_barcode.blank? # TODO: remove once we have added option for digitizing requestable items
      request_status?
    end

    def request_status?
      on_order? || in_process? || traceable? || aeon? || services.empty?
    end

    def help_me?
      ask_me? || (!available_for_digitizing? && !aeon?)
    end

    def available_for_appointment?
      !circulates? && !recap? && !charged? && !aeon? && !etas?
    end

    def will_submit_via_form?
      digitize? || pick_up? || ((on_order? || in_process? || traceable?) && user_barcode.present?)
    end

    # pickup location id on the item level
    def pickup_location_id
      item? && item['pickup_location_id'].present? ? item['pickup_location_id'] : ""
    end

    # pickup_location_code on the item level
    def pickup_location_code
      item? && item['pickup_location_code'].present? ? item['pickup_location_code'] : ""
    end

    def item_type
      item? && item['item_type'].present? ? item['item_type'] : ""
    end

    # item type on the item level
    def item_type_non_circulate?
      return true if ['NoCirc', 'Closed', 'Res-No'].include? item_type
      false
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

    def enum_value
      return "" unless item?
      item['enum']
    end

    def cron_value
      return "" unless item?
      item['chron']
    end

    # non voyager options
    def thesis?
      holding.key?("thesis") && holding["thesis"][:location_code] == 'mudd'
    end

    def numismatics?
      holding.key?("numismatics") && holding["numismatics"][:location_code] == 'num'
    end

    # Reading Room Request
    def aeon?
      location[:aeon_location] == true || (item.present? && item[:use_statement] == 'Supervised Use')
    end

    # at an open location users may go to
    def open?
      location[:open] == true
    end

    def recap?
      return false unless location_valid?
      library_code == 'recap'
    end

    def recap_edd?
      (scsb? && scsb_edd_collection_codes.include?(item[:collection_code])) ||
        ((location[:recap_electronic_delivery_location] == true) && !scsb?)
    end

    def missing?
      item[:status] == 'Missing'
    end

    def lewis?
      ['sci', 'scith', 'sciref', 'sciefa', 'sciss'].include?(location_code)
    end

    def plasma?
      location_code == 'ppl'
    end

    def preservation?
      location_code == 'pres'
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
      item_type_non_circulate? == false && location[:circulates] == true && open_libraries.include?(location[:library][:code])
    end

    def available_for_digitizing?
      open_libraries.include?(location[:library][:code])
    end

    def can_be_delivered?
      circulates? && !scsb_in_library_use? && !in_library_use_only?
    end

    def always_requestable?
      location[:always_requestable] == true
    end

    # Is the ReCAP Item from a partner location
    def scsb?
      scsb_locations.include?(location_code)
    end

    def use_restriction?
      scsb? && item.present? && item[:use_statement].present?
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
      item.present?
    end

    def item_data?
      item? && item[:id].present?
    end

    def temp_loc?
      item? && item[:temp_loc].present?
    end

    def on_reserve?
      item? && item[:on_reserve] == 'Y'
    end

    def inaccessible?
      item? && item[:status] == 'Inaccessible'
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
      location_valid? && location[:library][:code] == 'online' && (!etas? || bib["location"].first.casecmp("recap").zero?)
    end

    def urls
      return {} unless online? && bib['electronic_access_1display']
      JSON.parse(bib['electronic_access_1display'])
    end

    def charged?
      item? && (unavailable_statuses.include?(item[:status]) || unavailable_statuses.include?(item[:scsb_status]))
    end

    def hold_request?
      item? && item[:status] == 'Hold Request'
    end

    def enumerated?
      item? && item[:enum].present?
    end

    def pageable?
      !charged? && pageable_loc?
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

    def in_library_use_only?
      return false unless location["holding_library"]
      ["marquand", "lewis"].include? location["holding_library"]["code"]
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

    def open_libraries
      open = ['firestone', 'annexa', 'recap', 'marquand', 'mendel', 'stokes', 'eastasian', 'architecture', 'lewis', 'engineering']
      open << "online" if etas? && !bib["location"].first.casecmp('recap').zero?
      open
    end

    def location_code
      return nil if location.blank?
      location['code']
    end

    def location_label
      return nil if location.blank? || location["library"].blank?
      label = location["library"]["label"]
      label += " - #{location['label']}" if location["label"].present?
      label
    end

    def item_location_code
      if item? && item["location"].present?
        item['location'].to_s
      else
        location_code
      end
    end

    def library_code
      return bib["location"].first.downcase if location["code"] == "etas"
      return nil if location['library'].blank?
      location['library']['code']
    end

    def create_fill_in_requestable
      fill_in_req = Requestable.new(bib: bib, holding: holding, item: nil, location: location, user_barcode: user_barcode)
      fill_in_req.services = services
      fill_in_req
    end

    def libcal_url
      return unless available_for_appointment?
      "https://libcal.princeton.edu/seats?lid=#{code_to_libcal[location['library']['code']]}"
    end

    def etas?
      etas_limited_access || location[:code] == 'etas' || location[:code] == 'etasrcp'
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

      def scsb_edd_collection_codes
        %w[AR BR CA CH CJ CP CR CU EN EV GC GE GS HS JC JD LD LE ML SW UT NA NH NL NP NQ NS NW GN JN JO PA PB PN GP JP]
      end

      def location_valid?
        location.key?(:library) && location[:library].key?(:code)
      end

      def code_to_libcal
        {
          "firestone" => "1919", "engineering" => "7832", "lewis" => "3508", "stokes" => "2353", "eastasian" => "10604",
          "mendel" => "10653", "architecture" => "10655", "marquand" => "10656"
        }
      end
  end
end
