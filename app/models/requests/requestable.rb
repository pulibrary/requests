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
    attr_reader :patron
    attr_accessor :services

    delegate :pageable_loc?, to: :@pageable
    delegate :map_url, to: :@mappable
    delegate :illiad_request_url, :illiad_request_parameters, to: :@illiad
    delegate :campus_authorized, to: :@patron

    include Requests::Aeon

    # @param bib [Hash] Solr Document of the Top level Request
    # @param holding [Hash] Bib Data information on where the item is held (Marc liberation) parsed solr_document[holdings_1display] json
    # @param item [Hash] Item level data from bib data (https://bibdata.princeton.edu/availability?id= or mfhd=)
    # @param location [Hash] The has for a bib data holding (https://bibdata.princeton.edu/locations/holding_locations)
    # @param patron [Patron] the patron information about the current user
    def initialize(bib:, holding: nil, item: nil, location: nil, patron:)
      @bib = bib
      @holding = holding
      @item = item.present? ? Item.new(item) : Item::NullItem.new
      @location = location
      @services = []
      @patron = patron
      @user_barcode = patron.barcode
      @call_number = holding.first[1]['call_number_browse']
      @etas_limited_access = holding.first[1]["etas_limited_access"]
      @title = bib[:title_citation_display]&.first
      @pageable = Pageable.new(call_number: call_number, location_code: location_code)
      @mappable = Requests::Mapable.new(bib_id: bib[:id], holdings: holding, location_code: location_code)
      @illiad = Requests::Illiad.new(enum: item&.fetch(:enum, nil), chron: item&.fetch(:chron, nil), call_number: holding.first[1]['call_number_browse'])
    end

    ############# Drives what happens on the form #######################

    def digitize?
      (item_data? || !circulates?) && (on_shelf_edd? || (recap_edd? && !scsb_in_library_use?)) && !request_status?
    end

    def fill_in_digitize?
      !item_data? || digitize?
    end

    def pick_up?
      return false if user_barcode.blank? || etas? || !campus_authorized
      item_data? && (on_shelf? || recap? || annexa?) && circulates? && !in_library_use_only? && !scsb_in_library_use? && !request?
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
      !circulates? && !recap? && !charged? && !aeon? && !etas? && campus_authorized
    end

    def will_submit_via_form?
      digitize? || pick_up? || scsb_in_library_use? || ((on_order? || in_process? || traceable?) && user_barcode.present?)
    end

    delegate :pickup_location_id, :pickup_location_code, :item_type, :enum_value, :cron_value, :item_data?,
             :temp_loc?, :on_reserve?, :inaccessible?, :hold_request?, :enumerated?, :item_type_non_circulate?,
             :id, :use_statement, :collection_code, :missing?, :charged?, to: :item

    ## If the item doesn't have any item level data use the holding mfhd ID as a unique key
    ## when one is needed. Primarily for non-barcoded Annex items.
    def preferred_request_id
      if id.present?
        id
      else
        holding.first[0]
      end
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
      location[:aeon_location] == true || (use_statement == 'Supervised Use')
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
      (scsb? && scsb_edd_collection_codes.include?(collection_code)) ||
        ((location[:recap_electronic_delivery_location] == true) && !scsb?)
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
      scsb? && use_statement.present?
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
      location_valid? && location[:library][:code] == 'online' && !etas?
    end

    def urls
      return {} unless online? && bib['electronic_access_1display']
      JSON.parse(bib['electronic_access_1display'])
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
      open << "online" if etas?
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
      fill_in_req = Requestable.new(bib: bib, holding: holding, item: nil, location: location, patron: @patron)
      fill_in_req.services = services
      fill_in_req
    end

    def libcal_url
      return unless available_for_appointment?
      Libcal.url(location['library']['code'])
    end

    def etas?
      etas_limited_access || location[:code] == 'etas' || location[:code] == 'etasrcp'
    end

    private

      def scsb_locations
        ['scsbnypl', 'scsbcul']
      end

      def scsb_edd_collection_codes
        %w[AR BR CA CH CJ CP CR CU EN EV GC GE GS HS JC JD LD LE ML SW UT NA NH NL NP NQ NS NW GN JN JO PA PB PN GP JP]
      end

      def location_valid?
        location.key?(:library) && location[:library].key?(:code)
      end
  end
end
