module Requests
  class Holding
    attr_accessor :holding_id
    attr_accessor :location_code
    attr_accessor :status
    attr_accessor :library
    attr_accessor :summary_statement

    def initialize(hash)
      
    end

    def open?
    end

    def aeon?
    end

    def requestable?
    end

    def items?
    end

    def delivery_locations?
    end

    def online?
    end
  end
end
