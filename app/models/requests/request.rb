require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id

    include BorrowDirect
    include Requests::Bibdata

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd 
    # @option opts [User] :user current user object                                                    
    def initialize(params)

      @system_id = params[:system_id]
      @mfhd = params[:mfhd]
      @user = params[:user]
      solr_response = solr_doc(@system_id)
      @doc = parse_blacklight_solr_response(solr_response) # load the solr doc
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
              unless @locations.key? item_current_location(item)
                @locations[item_current_location(item)] = JSON.parse(self.location(item_current_location(item))).with_indifferent_access
              end
              params = build_requestable_params(
                { 
                  item: item, 
                  holding: holding_id, 
                  location: @locations[item_current_location(item)]
                } 
              )
              requestable_items << Requests::Requestable.new(params)
            end
          else
            params = build_requestable_params({holding: holding_id, location: @locations[self.holdings[holding_id]["location_code"]] } )
            requestable_items << Requests::Requestable.new(params)
          end
        end
        requestable_items
      else
        unless self.doc[:holdings_1display].nil?
          requestable_items = []
          if @mfhd
            params = build_requestable_params({ holding: @mfhd, location: @locations[self.holdings[@mfhd]["location_code"]]} )
            requestable_items << Requests::Requestable.new(params)
          elsif (self.thesis?)
            params = build_requestable_params({ holding: 'thesis', location: @locations[self.holdings['thesis']["location_code"]]} )
            requestable_items << Requests::Requestable.new(params)
          else
            self.holdings.each do |holding_id, holding_details|
              params = build_requestable_params({ holding: @mfhd, location: @locations[self.holdings[holding_id]["location_code"]]} )
              requestable_items << Requests::Requestable.new(params)
            end
          end
          requestable_items
        end
      end  
    end

    def route_requestable
      routed_requests = []
      self.requestable.each do |requestable|
        routed_requests << Requests::Router.new(requestable, @user)
      end
      routed_requests
    end

    def system_id
      @system_id
    end

    def serial?
      self.doc[:format] == 'Journal'
    end

    def available?
      self.items(@system_id)
    end

    # def on_order?
    #   unless @items?
    #     JSON.parse(self.items(@system_id)).has_key? "order"
    #   end
    # end

    def items?
      @items
    end

    def user(patron_id)
      user = current_patron(patron_id)
    end

    def holdings?
      self.holdings
    end

    def holdings
      JSON.parse(self.doc[:holdings_1display])
    end

    def locations
      @locations
    end

    def load_locations
      unless self.doc[:location_code_s].nil?
        holding_locations = { }
        self.doc[:location_code_s].each do |loc|
          holding_locations[loc] = JSON.parse(self.location(loc)).with_indifferent_access
        end
        holding_locations
      end
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      if @mfhd
        items_as_json = JSON.parse(self.items_by_mfhd(@mfhd))
        unless items_as_json.size == 0
          items_by_mfhd = {}
          items_with_symbols = items_to_symbols(items_as_json)
          items_by_mfhd[@mfhd] = items_with_symbols
          items_by_mfhd
        end
      elsif(self.thesis?)
        nil
      elsif(self.items(@system_id)) 
        items_by_mfhd = {}
        self.holdings.each do |holding|
          items_by_holding = JSON.parse(self.items_by_mfhd(holding[0]))
          items_by_mfhd[holding[0].to_s] = items_to_symbols(items_by_holding)
        end
        items_by_mfhd
      else
        nil
      end
    end

    def thesis?
      unless self.doc[:holdings_1display].nil?
        return true if parse_json(self.doc[:holdings_1display]).key?('thesis')
      end
    end

    # returns basic metadata for display on the request from via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def display_metadata
      {
        title: self.doc["title_citation_display"],
        author: self.doc["author_citation_display"],
        date:  self.doc["pub_date_display"]
      }
    end

    private
      # defaults come 
      def build_requestable_params(params)
        {
          bib: @doc,
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
        item['temp_location'] || item['perm_location']
      end
  end
end
