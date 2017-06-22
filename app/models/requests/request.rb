require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id
    attr_accessor :email
    attr_accessor :user_barcode
    attr_accessor :user_name
    attr_accessor :source
    attr_accessor :mfhd
    attr_reader :user

    include Requests::Bibdata
    include Requests::BdUtils
    include Requests::Ctx
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd voyager id
    # @option opts [User] :user current user object
    # @option opts [String] :source represents system that directed user to request form. i.e.
    def initialize(system_id:, mfhd: nil, user: nil, source: nil)
      @system_id ||= system_id
      @mfhd ||= mfhd
      @user ||= user
      @source ||= source
      ### These should be re-factored
      @doc ||= solr_doc(system_id)
      @requestable_unrouted ||= build_requestable
      @requestable ||= route_requests(@requestable_unrouted)
    end

    def doc
      @doc
    end

    def scsb?
      return true if /^SCSB-\d+/ =~ system_id.to_s
    end

    def requestable
      @requestable
    end

    def requestable_unrouted
      @requestable_unrouted
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
          values['items'].each { |item| barcodesort[item['barcode']] = item }
          availability_data.each do |item|
            barcodesort[item['itemBarcode']]['status'] = item['itemAvailabilityStatus']
          end
          barcodesort.values.each do |item|
            params = build_requestable_params(
              {
                item: item.with_indifferent_access,
                holding: { "#{id.to_sym}" => holdings[id] },
                location: locations[holdings[id]['location_code']]
              }
            )
            requestable_items << Requests::Requestable.new(params)
          end
        end
        requestable_items
      elsif !items.nil?
        requestable_items = []
        items.each do |holding_id, items|
          if !items.empty?
            items.each do |item|
              item_loc = item_current_location(item)
              ## This check is needed in case the item level data denotes a temporary
              ## location
              unless locations.key? item_loc
                locations[item_loc] = get_location(item_loc)
              end
              params = build_requestable_params(
                {
                  item: item.with_indifferent_access,
                  holding: { "#{holding_id.to_sym}" => holdings[holding_id] },
                  location: @locations[item_loc]
                }
              )
              # sometimes availability returns items without any status
              # see https://github.com/pulibrary/marc_liberation/issues/174
              unless item["status"].nil?
                requestable_items << Requests::Requestable.new(params)
              end
            end
          else
            params = build_requestable_params({ holding: { "#{holding_id.to_sym}" => holdings[holding_id] }, location: locations[holdings[holding_id]["location_code"]] })
            requestable_items << Requests::Requestable.new(params)
          end
        end
        requestable_items
      else
        unless doc[:holdings_1display].nil?
          requestable_items = []
          if @mfhd
            params = build_requestable_params({ holding: { "#{@mfhd.to_sym}" => holdings[@mfhd] }, location: locations[holdings[@mfhd]["location_code"]] })
            requestable_items << Requests::Requestable.new(params)
          elsif (thesis?)
            params = build_requestable_params({ holding: { "thesis" => holdings['thesis'].with_indifferent_access }, location: locations[holdings['thesis']["location_code"]] })
            requestable_items << Requests::Requestable.new(params)
          elsif (visuals?)
            params = build_requestable_params({ holding: { "visuals" => holdings['visuals'].with_indifferent_access }, location: locations[holdings['visuals']["location_code"]] })
            requestable_items << Requests::Requestable.new(params)
          else
            holdings.each do |holding_id, holding_details|
              params = build_requestable_params({ holding: { "#{holding_id.to_sym}" => holdings[holding_id] }, location: locations[holdings[holding_id]["location_code"]] })
              requestable_items << Requests::Requestable.new(params)
            end
          end
          requestable_items
        end
      end
    end

    def has_requestable?
      return true if requestable.size > 0
    end

    def has_single_aeon_requestable?
      if requestable.size == 1 and requestable.first.services.include? 'aeon'
        return true
      else
        return false
      end
    end

    # returns an array of requestable hashes of  grouped under a common mfhd
    def sorted_requestable
      sorted = {}
      requestable.each do |requestable|
        mfhd = requestable.holding.keys[0]
        if sorted.key? mfhd
          sorted[mfhd] << requestable
        else
          sorted[mfhd] = [requestable]
        end
      end
      sorted
    end

    # Does this request object have any pageable items?
    def has_pageable?
      services = []
      requestable.each do |request|
        request.services.each do |service|
          services << service
        end
      end
      services.uniq!
      if services.include? 'paging'
        true
      else
        false
      end
    end

    def fill_in_eligible
      fill_in = []
      unless requestable.any? { |request| request.services.include? 'on_order' }
        requestable.each do |request|
          unless (request.services & fill_in_services).empty?
            if request.has_item_data?
              fill_in << request.holding.first.first if request.item.key?('enum')
            else
              fill_in << request.holding.first.first
            end
          end
        end
      end
      return fill_in
    end

    def fill_in_services
      ["annexa", "annexb"]
    end

    # Does this request object have any available copies?
    def has_loanable_copy?
      copy_available = []
      requestable_unrouted.each do |request|
        if request.charged? || (request.aeon? || !request.circulates? || request.scsb?)
          copy_available << false
        else
          copy_available << true
        end
      end
      copy_available.uniq!
      if copy_available.include? true
        true
      else
        false
      end
    end

    def has_enumerated?
      enumerated = []
      requestable_unrouted.each do |request|
        enum = request.enumerated? ? true : false
        enumerated << enum
      end
      enumerated.include?(true) ? true : false
    end

    def route_requests(requestable_items)
      routed_requests = []
      return [] if requestable_items.blank?
      has_loanable = has_loanable_copy?
      requestable_items.each do |requestable|
        router = Requests::Router.new(requestable: requestable, user: @user, has_loanable: has_loanable)
        routed_requests << router.routed_request
      end
      routed_requests
    end

    def serial?
      return true if doc[:format].include? 'Journal'
    end

    def available?
      items_by_bib(@system_id)
    end

    def items?
      items
    end

    def holdings?
      holdings
    end

    def holdings
      @holdings ||= JSON.parse(doc[:holdings_1display] || '{}')
    end

    def locations
      @locations ||= load_locations
    end

    def items
      @items ||= load_items
    end

    def all_items_online?
      online = true
      requestable.each do |item|
        online = false unless item.online?
      end
      return online
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      mfhd_items = {}
      if thesis?
        return nil
      elsif visuals?
        return nil
      else
        if @mfhd && serial?
          items_as_json = items_by_mfhd(@mfhd)
          if items_as_json.size != 0
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

    def visuals?
      unless doc[:holdings_1display].nil?
        return true if parse_json(doc[:holdings_1display]).key?('visuals')
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

    def get_language
      doc["language_code_s"].first
    end

    def pickups
      @pickups ||= build_pickups
    end

    # should probably happen in the initializer
    def build_pickups
      pickup_locations = []
      DELIVERY_LOCATIONS.values.each do |pickup|
        if pickup["pickup_location"] == true
          pickup_locations << { label: pickup["label"], gfa_code: pickup["gfa_pickup"] }
        end
      end
      # pickup_locations.sort_by! { |loc| loc[:label] }
      sort_pickups(pickup_locations)
    end

    def default_pickups
      pickups
    end

    # if a Record is a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if has_loanable_copy? && has_enumerated?
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
            unless location[:delivery_locations].empty?
              location[:delivery_locations] = sort_pickups(location[:delivery_locations])
            end
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
