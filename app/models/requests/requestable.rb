module Requests
  class Requestable

    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location

    def initialize(params)
      @bib = params[:bib] # hash of bibliographic data
      @holding = params[:holding] # hash of holding data
      @item = params[:item] # hash of item data
      @location = params[:location] # hash of location matrix data
    end

    def type
      if @item
        'item'
      elsif @holding
        'holding'
      else
        'bib'
      end
    end

    def location_code
      @holding[:location_code]
    end

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def aeon?
      return true if @location[:aeon_location] == true  
    end

    def accessible?
      return true if @location[:open] == true
    end

    def requestable?
      return true if @location[:requestable] == true
    end

    def recap?
      return true if @location[:library][:code] == 'recap'
    end

    def item?
      @item
    end

    # This should a property of requestable. The Router can invoke this test when it looks
    # at item status and finds something unavailable. Need to confirm with Peter Bae if the only monographs rule holds
    # true for borrow direct. Currenly if a Record is not a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      return true if @bib[:format] == 'Book' && !self.aeon?
    end
  end
end
