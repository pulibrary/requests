require 'borrow_direct'

module Requests
  class BorrowDirect
    attr_reader :errors
    attr_reader :sent
    attr_reader :service_type
    attr_reader :handled_by
    attr_reader :isbn
    attr_reader :submission

    def initialize(submission)
      @submission = submission
      @errors = []
      @sent = []
      @handled_by = "borrow_direct"
      @isbn = submission.bib["isbn"].split(" ").first if submission.bib["isbn"].present?
      @pickup_location = "Firestone Library"
    end

    def handle
      bd_items = @submission.filter_items_by_service('bd')

      # handle any borrow direct items
      bd_items.each do |bd_item|
        handle_with_borrow_direct(bd_item: bd_item)
      end

      # hten handle any interlibrary loan only items
      ill_items = @submission.filter_items_by_service('ill') - bd_items
      ill_items.each do |item|
        handle_with_interlibrary_loan(item: item)
      end
    end

    private

      def handle_with_borrow_direct(bd_item:)
        request_number = ::BorrowDirect::RequestItem.new(@submission.user_barcode).make_request(@pickup_location, isbn: isbn)
        if request_number.present?
          @sent << { request_number: request_number }
        else
          handle_with_interlibrary_loan(item: bd_item)
        end
      rescue *::BorrowDirect::Error => error
        # duplicate request error, do not send again
        if error.to_s.starts_with?('PRIRI003')
          errors << { type: 'digitize', bibid: submission.bib, item: bd_item, user_name: submission.user_name, barcode: submission.user_barcode, error: "Ignoring duplicate Borrow Direct request: #{error}" }

        # borrow direct did not work handle with interlibrary loan
        else
          handle_with_interlibrary_loan(item: bd_item)
        end
      end

      def handle_with_interlibrary_loan(item:)
        @handled_by = "interlibrary_loan"
        client = IlliadTransactionClient.new(patron: @submission.patron, bib: @submission.bib, item: item, metadata_mapper_class: Requests::IlliadMetadata::Loan)
        transaction = client.create_request
        errors << { type: 'digitize', bibid: @submission.bib, item: item, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "Invalid Interlibrary Loan Request" } if transaction.blank?
        transaction
      end
  end
end
