require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_reader :system_id
    attr_reader :source
    attr_reader :mfhd
    attr_reader :user
    attr_reader :doc
    attr_reader :requestable
    attr_reader :requestable_unrouted
    attr_reader :holdings
    attr_reader :locations
    attr_reader :items
    attr_reader :pickups
    alias default_pickups pickups
    delegate :ctx, :openurl_ctx_kev, to: :@ctx_obj

    include Requests::Bibdata
    include Requests::BdUtils
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd voyager id
    # @option opts [User] :user current user object
    # @option opts [String] :source represents system that directed user to request form. i.e.
    def initialize(system_id:, mfhd: nil, user: nil, source: nil)
      @system_id = system_id
      @mfhd = mfhd
      @user = user
      @source = source
      ### These should be re-factored
      @doc = solr_doc(system_id)
      @holdings = JSON.parse(doc[:holdings_1display] || '{}')
      @locations = load_locations
      @items = load_items
      @pickups = build_pickups
      @requestable_unrouted = build_requestable
      @requestable = route_requests(@requestable_unrouted)
      @ctx_obj = Requests::SolrOpenUrlContext.new(solr_doc: @doc)
    end

    def scsb?
      return true if /^SCSB-\d+/ =~ system_id.to_s
    end

    ### builds a list of possible requestable items
    # returns a collection of requestable objects or nil
    def build_requestable
      return [] if doc.blank?
      if scsb?
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
          barcodesort = {}
          unless values['items'].nil?
            values['items'].each { |item| barcodesort[item['barcode']] = item }
            availability_data.each do |item|
              barcodesort[item['itemBarcode']]['status'] = item['itemAvailabilityStatus'] unless barcodesort[item['itemBarcode']].nil?
            end
          end
          barcodesort.values.each do |item|
            params = build_requestable_params(
              item: item.with_indifferent_access,
              holding: { id.to_sym.to_s => holdings[id] },
              location: locations[holdings[id]['location_code']]
            )
            requestable_items << Requests::Requestable.new(params)
          end
        end
        requestable_items
      elsif !items.nil?
        requestable_items = []
        barcodesort = {}
        if recap?
          availability_data = items_by_id(system_id, scsb_owning_institution(scsb_location))
          availability_data.each do |item|
            barcodesort[item['itemBarcode']] = item['itemAvailabilityStatus'] unless item['errorMessage'] == "Bib Id doesn't exist in SCSB database."
          end
        end
        items.each do |holding_id, items|
          if !items.empty?
            items.each do |item|
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
              requestable_items << Requests::Requestable.new(params) unless item["status"].nil?
            end
          else
            params = build_requestable_params(holding: { holding_id.to_sym.to_s => holdings[holding_id] }, location: locations[holdings[holding_id]["location_code"]])
            requestable_items << Requests::Requestable.new(params)
          end
        end
        requestable_items
      else
        unless doc[:holdings_1display].nil?
          requestable_items = []
          if @mfhd
            params = build_requestable_params(holding: { @mfhd.to_sym.to_s => holdings[@mfhd] }, location: locations[holdings[@mfhd]["location_code"]])
            requestable_items << Requests::Requestable.new(params)
          elsif thesis?
            params = build_requestable_params(holding: { "thesis" => holdings['thesis'].with_indifferent_access }, location: locations[holdings['thesis']["location_code"]])
            requestable_items << Requests::Requestable.new(params)
          else
            holdings.each do |holding_id, _holding_details|
              params = build_requestable_params(holding: { holding_id.to_sym.to_s => holdings[holding_id] }, location: locations[holdings[holding_id]["location_code"]])
              requestable_items << Requests::Requestable.new(params)
            end
          end
          requestable_items
        end
      end
    end

    def requestable?
      requestable.size.positive?
    end

    def single_aeon_requestable?
      (requestable.size == 1) && requestable.first.services.include?('aeon')
    end

    # returns an array of requestable hashes of  grouped under a common mfhd
    def sorted_requestable
      sorted = {}
      requestable.each do |requestable|
        mfhd = requestable.holding.keys[0]
        sorted[mfhd] ||= []
        sorted[mfhd] << requestable
      end
      sorted
    end

    # Does this request object have any pageable items?
    def any_pageable?
      services = requestable.map(&:services).flatten
      services.uniq!
      services.include? 'paging'
    end

    def fill_in_eligible(mfhd)
      fill_in = false
      unless (sorted_requestable[mfhd].first.services & ["on_order", "on_shelf", "online"]).present?
        if sorted_requestable[mfhd].any? { |r| !(r.services & fill_in_services).empty? }
          if sorted_requestable[mfhd].first.item_data?
            fill_in = true if sorted_requestable[mfhd].first.item.key?('enum')
          else
            fill_in = true
          end
        end
      end
      fill_in
    end

    def fill_in_services
      ["annexa", "annexb", "recap_no_items"]
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
        router = Requests::Router.new(requestable: requestable, user: @user, any_loanable: any_loanable)
        routed_requests << router.routed_request
      end
      routed_requests
    end

    def serial?
      if doc[:format].present?
        return true if doc[:format].include? 'Journal'
      end
    end

    def recap?
      locations.each do |_code, location|
        return true if location[:library][:code] == 'recap'
      end
    end

    def all_items_online?
      online = true
      requestable.each do |item|
        online = false unless item.online?
      end
      online
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      mfhd_items = {}
      if thesis?
        return nil
      else
        if @mfhd && serial?
          items_as_json = items_by_mfhd(@mfhd)
          if !items_as_json.empty?
            items_with_symbols = items_to_symbols(items_as_json)
            mfhd_items[@mfhd] = items_with_symbols
          else
            empty_mfhd = items_by_bib(@system_id)
            mfhd_items[@mfhd] = [empty_mfhd[@mfhd]]
          end
        else
          items_by_bib(@system_id).each do |holding_id, item_info|
            items_by_holding = if item_info[:more_items] == false
                                 if item_info[:status].starts_with?('On-Order') || item_info[:status].starts_with?('Pending Order')
                                   [item_info]
                                 elsif item_info[:status].starts_with?('Online')
                                   [item_info]
                                 else
                                   items_to_symbols(items_by_mfhd(holding_id))
                                 end
                               else
                                 items_to_symbols(items_by_mfhd(holding_id))
                               end
            mfhd_items[holding_id] = items_by_holding
          end
        end
        return mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
      end
    end

    def thesis?
      unless doc[:holdings_1display].nil?
        return true if parse_json(doc[:holdings_1display]).key?('thesis')
      end
    end

    # returns basic metadata for display on the request from via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def display_metadata
      {
        title: doc["title_citation_display"],
        author: doc["author_citation_display"]
      }
    end

    def language
      doc["language_iana_s"]&.first
    end

    # should probably happen in the initializer
    def build_pickups
      pickup_locations = []
      Requests::BibdataService.delivery_locations.values.each do |pickup|
        pickup_locations << { label: pickup["label"], gfa_code: pickup["gfa_pickup"], staff_only: pickup["staff_only"] } if pickup["pickup_location"] == true
      end
      # pickup_locations.sort_by! { |loc| loc[:label] }
      sort_pickups(pickup_locations)
    end

    # if a Record is a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if any_loanable_copies? && any_enumerated?
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

      def load_locations
        unless doc[:location_code_s].nil?
          holding_locations = {}
          doc[:location_code_s].each do |loc|
            location = get_location(loc)
            location[:delivery_locations] = sort_pickups(location[:delivery_locations]) unless location[:delivery_locations].empty?
            holding_locations[loc] = location
          end
          holding_locations
        end
      end

      def build_requestable_params(params)
        {
          bib: doc.with_indifferent_access,
          holding: params[:holding],
          item: params[:item],
          location: params[:location]
        }
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
  end
end
