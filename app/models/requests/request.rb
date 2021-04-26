require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :email
    attr_accessor :user_name
    attr_reader :system_id
    attr_reader :source
    attr_reader :mfhd
    attr_reader :patron
    attr_reader :doc
    attr_reader :requestable
    attr_reader :requestable_unrouted
    attr_reader :holdings
    attr_reader :locations
    attr_reader :items
    attr_reader :pick_ups
    alias default_pick_ups pick_ups
    delegate :ctx, :openurl_ctx_kev, to: :@ctx_obj

    include Requests::Bibdata
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd voyager id
    # @option opts [Patron] :patron current Patron object
    # @option opts [String] :source represents system that directed user to request form. i.e.
    def initialize(system_id:, mfhd:, patron: nil, source: nil)
      @system_id = system_id
      @mfhd = mfhd
      @patron = patron
      @source = source
      ### These should be re-factored
      @doc = solr_doc(system_id)
      @holdings = JSON.parse(doc[:holdings_1display] || '{}')
      include_etas_in_holdings(@holdings)
      @locations = load_locations
      @items = load_items
      @pick_ups = build_pick_ups
      @requestable_unrouted = build_requestable
      @requestable = route_requests(@requestable_unrouted)
      @ctx_obj = Requests::SolrOpenUrlContext.new(solr_doc: @doc)

      # scsb items are the only ones that come in without a MFHD parameter from the catalog now
      # set it for them, because they only ever have one location
      @mfhd ||= requestable.first.holding.keys[0] if requestable?
    end

    delegate :user, to: :patron

    def scsb?
      return true if /^SCSB-\d+/ =~ system_id.to_s
    end

    def requestable?
      requestable.size.positive?
    end

    def single_aeon_requestable?
      requestable.size == 1 && first_filtered_requestable&.services&.include?('aeon')
    end

    def first_filtered_requestable
      requestable&.first
    end

    # Does this request object have any pageable items?
    def any_pageable?
      services = requestable.map(&:services).flatten
      services.uniq!
      services.include? 'paging'
    end

    # Does this request object have any available copies?
    def any_loanable_copies?
      requestable_unrouted.any? { |request| !(request.charged? || (request.aeon? || !request.circulates? || request.scsb? || request.on_reserve?)) }
    end

    def any_enumerated?
      requestable_unrouted.any?(&:enumerated?)
    end

    def route_requests(requestable_items)
      routed_requests = []
      return [] if requestable_items.blank?
      any_loanable = any_loanable_copies?
      requestable_items.each do |requestable|
        router = Requests::Router.new(requestable: requestable, user: patron.user, any_loanable: any_loanable)
        routed_requests << router.routed_request
      end
      routed_requests
    end

    def serial?
      doc[:format].present? && doc[:format].include?('Journal')
    end

    def recap?
      locations.each_value do |location|
        return true if location[:library][:code] == 'recap'
      end
    end

    def all_items_online?
      requestable.map(&:online?).reduce(:&)
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      return nil if thesis? || numismatics?
      mfhd_items = if @mfhd && serial?
                     load_serial_items
                   else
                     # load_items_by_bib_id
                     load_items_by_mfhd
                   end
      mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
    end

    def thesis?
      doc[:holdings_1display].present? && parse_json(doc[:holdings_1display]).key?('thesis')
    end

    def numismatics?
      doc[:holdings_1display].present? && parse_json(doc[:holdings_1display]).key?('numismatics')
    end

    # returns basic metadata for display on the request from via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def display_metadata
      {
        title: doc["title_citation_display"],
        author: doc["author_citation_display"],
        isbn: doc["isbn_s"]
      }
    end

    def language
      doc["language_iana_s"]&.first
    end

    # should probably happen in the initializer
    def build_pick_ups
      pick_up_locations = []
      Requests::BibdataService.delivery_locations.each_value do |pick_up|
        pick_up_locations << { label: pick_up["label"], gfa_pickup: pick_up["gfa_pickup"], staff_only: pick_up["staff_only"] } if pick_up["pickup_location"] == true
      end
      # pick_up_locations.sort_by! { |loc| loc[:label] }
      sort_pick_ups(pick_up_locations)
    end

    # if a Record is a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if (any_loanable_copies? && any_enumerated?) || patron.guest?
        false
      else
        requestable.any? { |r| r.services.include? 'bd' }
      end
    end

    def ill_eligible?
      requestable.any? { |r| r.services.include? 'ill' }
    end

    def isbn_numbers?
      if doc.key? 'isbn_s'
        true
      else
        false
      end
    end

    def isbn_numbers
      doc['isbn_s']
    end

    def other_id
      doc['other_id_s'].first
    end

    def scsb_location
      doc['location_code_s'].first
    end

    private

      ### builds a list of possible requestable items
      # returns a collection of requestable objects or nil
      def build_requestable
        return [] if doc.blank?
        if scsb?
          build_scsb_requestable
        elsif !items.nil?
          build_requestable_with_items
        else
          build_requestable_from_data
        end
      end

      def build_scsb_requestable
        requestable_items = []
        ## scsb processing
        ## If mfhd present look for only that
        ## sort items by keys
        ## send query for availability by barcode
        ## overlay availability to the 'status' field
        ## make sure other fields map to the current data model for item in requestable
        ## adjust router to understand SCSB status
        availability_data = items_by_id(other_id, scsb_owning_institution(scsb_location))
        holdings.each do |id, values|
          requestable_items = build_holding_scsb_items(id: id, values: values, availability_data: availability_data, requestable_items: requestable_items)
        end
        requestable_items
      end

      def build_holding_scsb_items(id:, values:, availability_data:, requestable_items:)
        return requestable_items if values['items'].nil?
        barcodesort = {}
        values['items'].each { |item| barcodesort[item['barcode']] = item }
        availability_data.each do |item|
          barcodesort[item['itemBarcode']]['status'] = item['itemAvailabilityStatus'] unless barcodesort[item['itemBarcode']].nil?
        end
        barcodesort.each_value do |item|
          params = build_requestable_params(item: item.with_indifferent_access, holding: { id.to_sym.to_s => holdings[id] },
                                            location: locations[holdings[id]['location_code']])
          requestable_items << Requests::Requestable.new(params)
        end
        requestable_items
      end

      def build_requestable_with_items
        requestable_items = []
        barcodesort = {}
        if recap?
          availability_data = items_by_id(system_id, scsb_owning_institution(scsb_location))
          availability_data.each do |item|
            barcodesort[item['itemBarcode']] = item['itemAvailabilityStatus'] unless item['errorMessage'] == "Bib Id doesn't exist in SCSB database."
          end
        end
        items.each do |holding_id, mfhd_items|
          next if mfhd != holding_id
          requestable_items = build_requestable_from_mfhd_items(requestable_items: requestable_items, holding_id: holding_id, mfhd_items: mfhd_items, barcodesort: barcodesort)
        end
        requestable_items.compact
      end

      def build_requestable_from_data
        return if doc[:holdings_1display].nil?
        @mfhd ||= 'thesis' if thesis?
        @mfhd ||= 'numismatics' if numismatics?
        [build_requestable_from_holding(@mfhd, holdings[@mfhd].with_indifferent_access)]
      end

      def build_requestable_from_mfhd_items(requestable_items:, holding_id:, mfhd_items:, barcodesort:)
        if !mfhd_items.empty?
          mfhd_items.each do |item|
            requestable_items << build_requestable_mfhd_item(requestable_items, holding_id, item, barcodesort)
          end
        else
          requestable_items << build_requestable_from_holding(holding_id, holdings[holding_id])
        end
        requestable_items
      end

      def build_requestable_mfhd_item(_requestable_items, holding_id, item, barcodesort)
        item_loc = item_current_location(item)
        ## This check is needed in case the item level data denotes a temporary
        ## location
        locations[item_loc] = get_location(item_loc) unless locations.key? item_loc
        item['scsb_status'] = barcodesort[item['barcode']] unless barcodesort.empty?
        params = build_requestable_params(
          item: item.with_indifferent_access,
          holding: { holding_id.to_sym.to_s => holdings[holding_id] },
          location: @locations[item_loc]
        )
        # sometimes availability returns items without any status
        # see https://github.com/pulibrary/marc_liberation/issues/174
        Requests::Requestable.new(params) # unless item["status"].nil?
      end

      def build_requestable_from_holding(holding_id, holding)
        params = build_requestable_params(holding: { holding_id.to_sym.to_s => holding }, location: locations[holding["location_code"]])
        Requests::Requestable.new(params)
      end

      def load_locations
        return if doc[:location_code_s].nil?
        holding_locations = {}
        doc[:location_code_s].each do |loc|
          location = get_location(loc)
          location[:delivery_locations] = sort_pick_ups(location[:delivery_locations]) if location[:delivery_locations]&.present?
          holding_locations[loc] = location
        end
        holding_locations
      end

      def build_requestable_params(params)
        {
          bib: doc.with_indifferent_access,
          holding: params[:holding],
          item: params[:item],
          location: params[:location],
          patron: patron
        }
      end

      # Not sure why this method exists
      def load_serial_items
        mfhd_items = {}
        items_as_json = items_by_mfhd(@system_id, @mfhd)
        unless items_as_json.empty?
          items_with_symbols = items_to_symbols(items_as_json)
          mfhd_items[@mfhd] = items_with_symbols
        end
        # else
        #   empty_mfhd = items_by_bib(@system_id)
        #   mfhd_items[@mfhd] = [empty_mfhd[@mfhd]]
        # end
        mfhd_items
      end

      ## this method should be the only place we load item availability
      def load_items_by_mfhd
        mfhd_items = {}
        items_by_mfhd(@system_id, @mfhd).each do |item_info|
          mfhd_items[@mfhd] = load_item_for_holding(holding_id: @mfhd, item_info: item_info)
        end
        mfhd_items
      end

      # def load_items_by_bib_id
      #   mfhd_items = {}
      #   items_by_bib(@system_id).each do |holding_id, item_info|
      #     next if @mfhd != holding_id
      #     mfhd_items[holding_id] = load_item_for_holding(holding_id: holding_id, item_info: item_info)
      #   end
      #   mfhd_items
      # end

      def load_item_for_holding(holding_id:, item_info:)
        if item_info[:more_items] == false
          if item_info[:status].starts_with?('On-Order') || item_info[:status].starts_with?('Pending Order')
            [item_info]
          elsif item_info[:status].starts_with?('Online')
            [item_info]
          else
            ## we don't need to call this again
            items_to_symbols(items_by_mfhd(@system_id, holding_id))
          end
        else
          ## we don't need to call this again
          items_to_symbols(items_by_mfhd(@system_id, holding_id))
        end
      end

      def items_to_symbols(items = [])
        items_with_symbols = []
        items.each do |item|
          items_with_symbols << item.with_indifferent_access
        end
        items_with_symbols
      end

      def item_current_location(item)
        item['temp_loc'] || item['location']
      end

      def include_etas_in_holdings(holdings)
        holdings.each do |_key, holding|
          if holding["location_code"] != "scsbcul" || !doc.key?("oclc_s")
            holding["etas_limited_access"] = false
          else
            access = hathi_etas_status(doc["oclc_s"].first)
            holding["etas_limited_access"] = access.select { |r| r["status"] == "DENY" }.present?
          end
        end
      end
  end
end
