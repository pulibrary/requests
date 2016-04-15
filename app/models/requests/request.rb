require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id

    include BorrowDirect
    include Requests::Bibdata

    # params
    def initialize(params)
      @system_id = params[:system_id]
      @mfhd = params[:mfhd]
      @user = params[:user]
      solr_response = solr_doc(@system_id)
      @doc = parse_blacklight_solr_response(solr_response) # load the solr doc
      @items = load_items # hash of item data if nil only holdings level data available
    end

    def doc
      @doc
    end

    ### builds a list of possible requestable items
    def requestable
      requestable_items = []
      @items.each do |item|
        params = build_requestable_params(item)
        requestable_items << Requests::Requestable.new(params)
      end
      requestable_items
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
      self.doc[:holdings_1display]
    end

    def title
      self.doc[:title_display] || "Untitled"
    end

    def locations?
      self.doc[:location_code_s]
    end

    def load_locations
      holding_locations = { }
      self.doc[:location_code_s].each do |loc|
        holding_locations[loc] = JSON.parse(self.location(loc)).with_indifferent_access
      end
      holding_locations
    end

    def load_items
      if @mfhd
        items_as_json = JSON.parse(self.items_by_mfhd(@mfhd))
        items_with_symbols = items_to_symbols(items_as_json)
      elsif(self.thesis?)
        nil
      elsif()
        items_to_json(self.items)
      end
    end

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def holding_locations
      @holding_locations
    end

    # returns basic metadata for display on the request from via solr_doc values
    # Fields to return
    # :
    def display_metadata

    end

    private
      # defaults come 
      def build_requestable_params(item)
        {
          bib: @doc,
          holding: holdings[@mfhd]
        }
      end

      def items_to_symbols(items = [])
        items_with_symbols = []
        items.each do |item|
          items_with_symbols << item.with_indifferent_access
        end
        items_with_symbols
      end
  end
end
