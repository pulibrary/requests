require 'faraday'

module Requests
  class Clancy
    attr_reader :clancy_conn, :api_key, :errors, :service_types

    def initialize(submission)
      @service_types = ['clancy_in_library']
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
    end

    def handle
      service_types.each do |service_type|
        items = @submission.filter_items_by_service(service_type)
        items.each do |item|
          handle_item(item)
        end
      end
    end

    def submitted
      @sent
    end

    private

      def handle_item(item)
        # place the item on hold
        hold = Requests::HoldItem.new(@submission, service_type: item["type"])

        if hold.errors.empty?
          # request it from the clancy facility
          clancy_item = ClancyItem.new(barcode: item[:barcode])
          status = clancy_item.request(patron: @submission.patron, hold_id: hold_id(item_barcode: item[:barcode], patron_barcode: @submission.patron.barcode))
          @errors << { type: 'clancy', error: clancy_item.errors.first } unless status
        else
          @errors << hold.errors.first.merge(type: 'clancy_hold')
        end
      end

      def hold_id(item_barcode:, patron_barcode:)
        id = "#{item_barcode}-#{patron_barcode}-#{Time.zone.now.to_i}"
        Rails.logger.debug("Requesting clancy item with id: #{id}")
        id
      end
  end
end
