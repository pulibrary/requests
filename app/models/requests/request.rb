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
      @items = load_items # hash of item data if nil only holdings level data available
    end

    def doc
      @doc
    end

    ### builds a list of possible requestable items
    ## Do we want to this to return an empty array or 
    def requestable
      if !@items.nil?
        requestable_items = []
        @items.each do |item|
          params = build_requestable_params(item)
          requestable_items << Requests::Requestable.new(params)
        end
        requestable_items
      else
        unless self.doc[:holdings_1display].nil?
          requestable_items = []
          params = build_requestable_params
          requestable_items << Requests::Requestable.new(params)
          requestable_items
        end
      end 
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
        unless items_as_json.size == 0
          items_with_symbols = items_to_symbols(items_as_json)
        end
      elsif(self.thesis?)
        nil
      elsif(self.items(@system_id))
        items_to_symbols(JSON.parse(self.items(@system_id)))
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
    # Fields to return
    # :
    def display_metadata
      {
        title: self.doc
      }
    end

    private
      # defaults come 
      def build_requestable_params(item = nil)
        {
          bib: @doc,
          holding: holding_id,
          item: item
        }
      end

      def holding_id
        if !@mfhd.nil?
          holdings[@mfhd]
        elsif(self.thesis?)
          "thesis"
        else
          nil
        end
        # insert other types as they need support
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
