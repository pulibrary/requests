require 'email_validator'

module Requests
  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 } # , format: { message: "Supply a Valid Email Address" } #, on: :submit
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 } # ,  format: { message: "Name Can't be Blank" } #, on: :submit
    validates :user_barcode, allow_blank: true, presence: true, length: { minimum: 5, maximum: 14 },
                             format: { with: /(^ACCESS$|^access$|^\d{14}$)/i, message: "Please supply a valid library barcode or type the value 'ACCESS'" }
    validate :item_validations # , presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params, patron)
      @user = patron.with_indifferent_access if patron
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
      @bd = params[:bd]
    end

    attr_reader :user, :success_messages

    def email
      @user["active_email"]
    end

    def source
      @user["source"]
    end

    def user_name
      @user["netid"]
    end

    attr_reader :items

    attr_reader :bd

    def filter_items_by_service(service)
      @items.select { |item| item["type"] == service }
    end

    def selected_items(requestable_list)
      items = requestable_list.select { |r| r unless r[:selected] == 'false' || !r.key?('selected') }
      items.map { |item| categorize_by_delivery_and_location(item) }
    end

    def item_validations
      validates_with Requests::SelectedItemsValidator
    end

    def user_barcode
      @user["barcode"]
    end

    attr_reader :bib

    def id
      @bib[:id]
    end

    def scsb?
      items = @items.select { |item| ['scsbnypl', 'scsbcul'].include? item["location_code"] }
      return true unless items.empty?
      return false if items.empty?
    end

    def service_types
      @types ||= @items.map { |item| item['type'] }.uniq
      @types
    end

    def service_locations
      @locations ||= @items.map { |item| item['location'] }.uniq
      @locations
    end

    def process_submission
      @services = []
      @success_messages = []

      process_hold
      process_recall
      process_recap
      process_borrow_direct
      process_digitize

      # if !recap && !recall && !bd !(a1 & a2).empty?
      if generic_service_only?
        @services << Requests::Generic.new(self)
        success_messages << I18n.t('requests.submit.success')
      end

      @success_messages = generate_success_messages(@success_messages)

      @services
    end

    def service_errors
      return [] if @services.blank?
      @services.map(&:errors).flatten
    end

    def pickup_location
      Requests::BibdataService.delivery_locations[items.first["pickup"]]["library"]
    end

    def access_only?
      user_barcode == 'ACCESS'
    end

    private

      # rubocop:disable Metrics/MethodLength
      def categorize_by_delivery_and_location(item)
        if item["library_code"] == 'recap' && (item["type"] == "digitize_fill_in" || item["type"] == "recap_no_items")
          item["type"] = "recap_no_items"
        elsif item["library_code"] == 'recap'
          item["type"] = "recap"
          item["type"] += "_edd" if edd?(item)
        elsif item["type"] == "paging"
          item["type"] = "digitize" if edd?(item)
        elsif print?(item) && item["library_code"] == 'annexa'
          item["type"] = "annexa"
        elsif edd?(item) && item["library_code"].present?
          item["type"] = "digitize"
        elsif print?(item) && item["library_code"].present?
          item["type"] = "on_shelf"
        end
        item
      end
      # rubocop:enable Metrics/MethodLength

      def edd?(item)
        # return false if item["type"] == "digitize_fill_in"
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "edd"
      end

      def print?(item)
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "print"
      end

      def delivery_mode(item)
        item["delivery_mode_#{item['item_id']}"]
      end

      def process_hold
        return unless service_types.include? 'on_shelf'
        @services << Requests::HoldItem.new(self)
      end

      def process_recall
        return unless service_types.include? 'recall'
        @services << Requests::Recall.new(self)
      end

      def process_digitize
        return unless service_types.include?('digitize')
        @services << if access_only?
                       # Access users cannot use recap service directly
                       Requests::Generic.new(self)
                     else
                       Requests::DigitizeItem.new(self)
                     end
      end

      def process_recap
        return if (['recap', 'recap_edd', 'recap_in_library'] & service_types).blank?
        @services << if access_only?
                       # Access users cannot use recap service directly
                       Requests::Generic.new(self)
                     else
                       Requests::Recap.new(self)
                     end
      end

      def process_borrow_direct
        return unless service_types.include? 'bd'
        bd_success_message = I18n.t('requests.submit.bd_success')
        bd_request = Requests::BorrowDirect.new(self)
        bd_request.handle
        @services << bd_request
        success_messages << "#{bd_success_message} Your request number is #{bd_request.sent[0][:request_number]}" unless bd_request.errors.count >= 1
      end

      def generic_service?(type)
        !non_generic_services.include?(type)
      end

      def generic_service_only?
        (service_types & non_generic_services).empty?
      end

      def non_generic_services
        ['bd', 'recap', 'recall', 'on_shelf', 'digitize']
      end

      def generate_success_messages(success_messages)
        service_types.each do |type|
          success_messages << I18n.t("requests.submit.#{type}_success") unless generic_service?(type)
        end
        success_messages
      end
  end
end
