require 'email_validator'

module Requests
  class SelectedItemsValidator < ActiveModel::Validator
    def mail_services
      ["paging", "pres", "annexa", "annexb", "trace", "on_order", "in_process", "ppl", "lewis"]
    end

    def validate(record)
      unless record.items.size >= 1 && !record.items.any? { |item| defined? item.selected }
        record.errors[:items] << { "empty_set" => { 'text' => 'Please Select an Item to Request!', 'type' => 'options' } }
      end
      record.items.each do |selected|
        record = validate_selected(record, selected)
      end
    end

    private

      def validate_selected(record, selected)
        return unless selected['selected'] == 'true'

        case selected["type"]
        when 'bd'
          validate_recall_or_bd(record, selected, pickup_phrase: 'delivery of your borrow direct item', action_phrase: 'requested via Borrow Direct')
        when 'recap_no_items'
          validate_recap_no_items(record, selected)
        when 'recap'
          validate_recap(record, selected)
        when *(mail_services + ['recall'])
          validate_recall_or_bd(record, selected)
        else
          record.errors[:items] << { selected['mfhd'] => { 'text' => 'Please choose a Request Method for your selected item.', 'type' => 'pickup' } }
        end
      end

      def validate_recall_or_bd(record, selected, pickup_phrase: 'your selected recall item', action_phrase: 'Recalled')
        return unless validate_item_id(record: record, selected: selected, action_phrase: action_phrase)

        item_id = selected['item_id']
        return unless selected['pickup'].blank?

        record.errors[:items] << { item_id => { 'text' => "Please select a pickup location for #{pickup_phrase}", 'type' => 'pickup' } }
      end

      def validate_recap_no_items(record, selected)
        return if selected['pickup'].present?

        record.errors[:items] << { selected['mfhd'] => { 'text' => 'Please select a pickup location for your selected ReCAP item', 'type' => 'pickup' } }
      end

      def validate_recap(record, selected)
        return unless validate_item_id(record: record, selected: selected, action_phrase: 'Requested from Recap')
        validate_delivery_mode(record: record, selected: selected)
      end

      def validate_delivery_mode(record:, selected:)
        item_id = selected['item_id']

        if selected["delivery_mode_#{item_id}"].nil?
          record.errors[:items] << { item_id => { 'text' => 'Please select a delivery type for your selected recap item', 'type' => 'options' } }
        else
          delivery_type = selected["delivery_mode_#{item_id}"]
          if delivery_type == 'print' && selected['pickup'].empty?
            record.errors[:items] << { item_id => { 'text' => 'Please select a pickup location for your selected recap item', 'type' => 'pickup' } }
          end
          if delivery_type == 'edd'
            if selected['edd_art_title'].empty?
              record.errors[:items] << { item_id => { 'text' => 'Please specify title for the selection you want digitized.', 'type' => 'options' } }
            end
          end
        end
      end

      def validate_item_id(record:, selected:, action_phrase:)
        return true if selected['item_id'].present?

        record.errors[:items] << { selected['mfhd'] => { 'text' => "Item Cannot be #{action_phrase}, see circulation desk.", 'type' => 'options' } }
        false
      end
  end

  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 } # , format: { message: "Supply a Valid Email Address" } #, on: :submit
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 } # ,  format: { message: "Name Can't be Blank" } #, on: :submit
    validates :user_barcode, presence: true, length: { minimum: 5, maximum: 14 },
                             format: { with: /(^ACCESS$|^access$|^\d{14}$)/i, message: "Please supply a valid library barcode or type the value 'ACCESS'" }
    validate :item_validations # , presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params)
      @user = params[:request]
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
      @bd = params[:bd]
    end

    def user
      @user
    end

    def email
      @user["email"]
    end

    def source
      @user["source"]
    end

    def user_name
      @user["user_name"]
    end

    def items
      @items
    end

    def bd
      @bd
    end

    def filter_items_by_service(service)
      @items.select { |item| item["type"] == service }
    end

    def selected_items(requestable_list)
      requestable_list.select { |r| r unless (r[:selected] == 'false' || !r.key?('selected')) }
    end

    def item_validations
      validates_with Requests::SelectedItemsValidator
    end

    def user_barcode
      @user["user_barcode"]
    end

    def bib
      @bib
    end

    def id
      @bib[:id]
    end

    def scsb?
      items = @items.select { |item| ['scsbnypl', 'scsbcul'].include? item["location_code"] }
      return true unless items.empty?
      return false if items.empty?
    end

    def service_types
      types = []
      @items.each do |item|
        types << item['type']
      end
      types.uniq!
      types
    end
  end
end
