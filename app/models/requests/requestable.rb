module Requests
  class Requestable

    def initialize(params)
      @bib = params[:bib] # has of bib values
      @holding = params[:holding] || nil # hash of holding values
      @location = params[:location] || nil # hash of location matrix data
      @item = params[:item] || nil # hash of item values
    end

    def location_code
      @holding[:location_code]
    end

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def aeon?
    end

  end
end
