require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id

    include BorrowDirect
    include Requests::Bibdata

    def initialize(params)
      @system_id = params[:system_id]
      @mfhd_id = params[:mfhd] || nil
      @doc = parse_solr_response(solr_doc(system_id)) # load the solr doc
      @holding_locations = load_locations
      @items = load_items # hash of item data
    end

    def doc
      @doc
    end

    ### builds a construction of requestable items
    def requestable

    def system_id
      @system_id
    end

    def serial?
      self.doc[:format] == 'Journal'
    end

    def available?
      self.items(@system_id)
    end

    def on_order?
      unless @items?
        return true if JSON.parse(self.items(@system_id)).has_key? "order"
      end
    end

    def has_items?
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
      if @mfhd_id
        self.items_by_mfhd
      else
        self.items
      end
    end

    def holding_locations
      @holding_locations
    end
  end
end
