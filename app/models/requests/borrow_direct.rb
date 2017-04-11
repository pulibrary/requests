require 'borrow_direct'

module Requests
  class BorrowDirect

    attr_reader :errors
    attr_reader :sent
    attr_reader :service_type

    def initialize(submission)
      @submission = submission
      @service_type = 'bd'
      @errors = []
      @sent = []
    end

    def handle
      items = @submission.filter_items_by_service(@service_type)
      ## hack there can only be one
      bd_item = items.first
      begin
        if bd_item['auth_id'].nil?
          request_number = ::BorrowDirect::RequestItem.new(@submission.user_barcode).make_request(bd_item['pickup'], bd_item['query_params'])
        else
          request_number = ::BorrowDirect::RequestItem.new(@submission.user_barcode).with_auth_id(bd_item['auth_id']).make_request(bd_item['pickup'], bd_item['query_params'])
        end
        ## request number response indicates attempt was successful
        @sent <<  { request_number: request_number }
      rescue *::BorrowDirect::Error => error
        @errors << { error: error.message }
      end
    end
  end
end
