require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :system_id

    include BorrowDirect
    include Requests::Bibdata

    def initialize(system_id)
      @system_id = system_id
      @doc = parse_solr_response(solr_doc(system_id))
      @holding_locations = load_locations
    end

    def doc
      @doc
    end

    def system_id
      @system_id
    end

    def thesis?
      return true if @system_id =~ /^dsp.+/
    end

    def serial?
      self.doc[:format] == 'Journal'
    end

    def available?
      self.items(@system_id)
    end

    def on_order?
      unless self.items(@system_id).nil?
        return true if JSON.parse(self.items(@system_id)).has_key? "order"
      end
    end

    def has_items?
      self.items(@system_id)
    end

    def user(patron_id)
      user = current_patron(patron_id)
    end

    # If Record is not a serial/multivolume
    def borrow_direct_eligible?
      self.doc[:format] == 'Book'
    end

    # actually check to see if borrow direct is available
    def borrow_direct_available?
    end
    
    #When ISBN Match
    def borrow_direct_exact?
    end

    # When Title or Author Matches
    def borrow_direct_fuzzy?
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

    def has_online_holdings?
      return true if @holding_locations.has_key?('elf1')
    end

    def locations?
      self.doc[:location_code_s]
    end

    def load_locations
      holding_locations = Hash.new()
      self.doc[:location_code_s].each do |loc|
        holding_locations[loc] = JSON.parse(self.location(loc)).with_indifferent_access
      end
      holding_locations
    end

    def holding_locations
      @holding_locations
    end
    ## Called when request is "submitted"
    # def send *args

    # end

    # def log

    # end

  end
end
