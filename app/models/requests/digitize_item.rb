require 'faraday'

module Requests
  class DigitizeItem
    include Requests::Voyager

    def initialize(submission)
      @service_type = 'digitize'
      @submission = submission
      @errors = []
      @sent = []
      handle
    end

    def handle
      items = @submission.filter_items_by_service(@service_type)
      items.each do |item|
        item_status = handle_item(item: item)
        item["transaction_number"] = item_status["TransactionNumber"].to_s
        @sent << item_status unless item_status.blank?
      end
      return false if @errors.present?
    end

    def submitted
      @sent
    end

    attr_reader :errors

    private

      def handle_item(item:)
        client = IlliadTransactionClient.new(user: @submission.user, bib: @submission.bib, item: item)
        transaction = client.create_request
        errors << ["Invalid Digitization requests"] if transaction.blank?
        transaction
      end
  end
end
