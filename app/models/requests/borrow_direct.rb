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
      ## bd is only a valid type for non-enumerated works so there will always only be a single item with a 'bd' service type.
      bd_item = items.first
      begin
        request_number = ::BorrowDirect::RequestItem.new(@submission.user_barcode).make_request(bd_item['pick_up'], isbn: @submission.bd['query_params'])
        # request_number = if @submission.bd['auth_id'].nil?
        #                    ::BorrowDirect::RequestItem.new(@submission.user_barcode).make_request(bd_item['pick_up'], { isbn: @submission.bd['query_params'] })
        #                  else
        #                    ::BorrowDirect::RequestItem.new(@submission.user_barcode).with_auth_id(@submission.bd['auth_id']).make_request(bd_item['pick_up'], { isbn: @submission.bd['query_params'] })
        #                  end
        ## request number response indicates attempt was successful
        @sent << { request_number: request_number }
      rescue *::BorrowDirect::Error => error
        @errors << { error: error.message }
      end
    end
  end
end
