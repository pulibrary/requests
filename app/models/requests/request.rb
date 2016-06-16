require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id
    attr_accessor :email
    attr_accessor :user_barcode
    attr_accessor :user_name

    include BorrowDirect
    include Requests::Bibdata

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd 
    # @option opts [User] :user current user object                                                    
    def initialize(params)
      @system_id = params[:system_id]
      @mfhd = params[:mfhd]
      @user = params[:user]
      @doc = solr_doc(@system_id)
      @locations = load_locations
      @items = load_items # hash of item data if nil only holdings level data available
    end

    def doc
      @doc
    end

    ### builds a list of possible requestable items
    # returns a collection of requestable objects or nil
    def requestable
      if !@items.nil?
        requestable_items = []
        @items.each do |holding_id, items|
          if !items.empty?
            items.each do |item|
              item_loc = item_current_location(item)
              unless @locations.key? item_loc
                @locations[item_loc] = get_location(item_loc)
              end
              params = build_requestable_params(
                { 
                  item: item, 
                  holding: { "#{holding_id.to_sym}" => holdings[holding_id] },
                  location: @locations[item_loc]
                } 
              )
              requestable_items << Requests::Requestable.new(params)
            end
          else
            params = build_requestable_params({holding: { "#{holding_id.to_sym}" => holdings[holding_id] }, location: @locations[holdings[holding_id]["location_code"]] } )
            requestable_items << Requests::Requestable.new(params)
          end
        end
        route_requests(requestable_items)
      else
        unless doc[:holdings_1display].nil?
          requestable_items = []
          if @mfhd
            params = build_requestable_params({ holding: { "#{@mfhd.to_sym}" => holdings[@mfhd] }, location: @locations[holdings[@mfhd]["location_code"]]} )
            requestable_items << Requests::Requestable.new(params)
          elsif (thesis?)
            params = build_requestable_params({ holding: { "thesis" => {} }, location: @locations[holdings['thesis']["location_code"]]} )
            requestable_items << Requests::Requestable.new(params)
          elsif (visuals?)
            params = build_requestable_params({ holding: { "visuals" => {} }, location: @locations[holdings['visuals']["location_code"]]} )
            requestable_items << Requests::Requestable.new(params)
          else
            holdings.each do |holding_id, holding_details|
              params = build_requestable_params({ holding: { "#{holding_id.to_sym}" => holdings[holding_id] }, location: @locations[holdings[holding_id]["location_code"]] } )
              requestable_items << Requests::Requestable.new(params)
            end
          end
          route_requests(requestable_items)
        end
      end  
    end

    def has_requestable?
      return true if requestable.size > 0
    end

    # returns an array of requestable hashes of  grouped under a common mfhd
    def sorted_requestable
      sorted = { }
      requestable.each do |requestable|
        mfhd = requestable.holding.keys[0]
        if sorted.key? mfhd
          sorted[mfhd] << requestable
        else
          sorted[mfhd] = [ requestable ]
        end
      end
      sorted
    end

    # Does request have any pageable items
    def has_pageable?
      services = []
      requestable.each do |request|
        request.services.each do |service|
          services << service
        end
      end
      services.uniq!
      if services.include? 'paging'
        return true
      else
        nil
      end
    end

    def route_requests(requestable_items)
      routed_requests = []
      requestable_items.each do |requestable|
        router = Requests::Router.new(requestable, @user)
        routed_requests << router.routed_request
      end
      routed_requests
    end

    def system_id
      @system_id
    end

    def serial?
      doc[:format] == 'Journal'
    end

    def available?
      items_by_bib(@system_id)
    end

    def items?
      @items
    end

    def user
      @user
    end

    def holdings?
      holdings
    end

    def holdings
      JSON.parse(doc[:holdings_1display] || '{}')
    end

    def locations
      @locations
    end

    def load_locations
      unless doc[:location_code_s].nil?
        holding_locations = {}
        doc[:location_code_s].each do |loc|
          holding_locations[loc] = get_location(loc)
        end
        holding_locations
      end
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      mfhd_items = {}
      if !thesis?
        if @mfhd
          items_as_json = items_by_mfhd(@mfhd)
          unless items_as_json.size == 0
            items_with_symbols = items_to_symbols(items_as_json)
            mfhd_items[@mfhd] = items_with_symbols
          end
        else
          items_by_bib(@system_id).each do |holding_id, item_info|
            items_by_holding = if item_info[:more_items] == false
              if item_info[:status].starts_with?('On-Order')
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
      end
      mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
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
        author: doc["author_citation_display"],
        date:  doc["pub_date_display"]
      }
    end

    private
      # defaults come 
      def build_requestable_params(params)
        {
          bib: { id: @doc['id'] },
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
