require 'faraday'
require 'cobravsmongoose'

module Requests
  class IllToEdd
    include Requests::Illiad

    def initialize(params)
      @params = params
      @errors = []
      handle
    end

    def handle
      validate_tn
    end

    def returned
      r = get_response(@params)
      unless r.status == 200
        @errors << { error: "Error retrieving transaction." }
      end

      if errors.any?
        response = errors.to_json
      else
        response = r.body.to_json
      end
    end

    def errors
      @errors
    end

    def validate_tn
      integer = (/^\d+$/)
      unless @params['transaction_number'] =~ integer
        @errors << { error: "Invalid transaction number." }
      end
    end

  end
end
