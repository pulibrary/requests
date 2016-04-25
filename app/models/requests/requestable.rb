module Requests
  class Requestable

    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location

    def initialize(params)
      @bib = params[:bib] # has of bib values
      @holding = params[:holding] || nil # hash of holding values
      @location = params[:location] || nil # hash of location matrix data
      @item = params[:item] || nil # hash of item values
    end

    def 

    def location_code
      @holding[:location_code]
    end

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def aeon?
    end

    def available?
    end

    def item?
      @item
    end
    # This should a property of requestable. The Router can invoke this test when it looks
    # at item status and finds something unavailable. Need to confirm with Peter Bae if the only monographs rule holds
    # true for borrow direct. Currenly if a Record is not a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if @requestable.item[:status] == 'check for not available' and self.doc[:format] == 'Book'
        return true
      end
    end
  end
end
