module Requests
  class Requestable

    include Requests::Bibdata

    def initialize(params)
      @system_id = params[:system_id]
      @holding_id = params[:holding_id] || nil
      @item_id = params[:item_id] || nil
      unless @holding_id.nil?
        @holding = {}
      end
    end

    def location_code
      @holding[:location_code]
    end

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def aeon?
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
  end
end
