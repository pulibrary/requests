module Requests
  class Service

    def initialize(params)
      @type = params[:type]
    end

    def handle
      raise Exception.new("#{self.class}: handle() must be implemented by Service concrete sub-class, for standard services!")
    end

    def type
      @type
    end
  end
end