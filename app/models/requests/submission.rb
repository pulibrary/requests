require 'email_validator'

module Requests
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

    attr_reader :user, :success_messages

    def email
      @user["email"]
    end

    def source
      @user["source"]
    end

    def user_name
      @user["user_name"]
    end

    attr_reader :items

    attr_reader :bd

    def filter_items_by_service(service)
      @items.select { |item| item["type"] == service }
    end

    def selected_items(requestable_list)
      requestable_list.select { |r| r unless r[:selected] == 'false' || !r.key?('selected') }
    end

    def item_validations
      validates_with Requests::SelectedItemsValidator
    end

    def user_barcode
      @user["user_barcode"]
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
      types = []
      @items.each do |item|
        types << item['type']
      end
      types.uniq!
      types
    end

    def process_submission
      @services = []
      @success_messages = []
      process_hold
      process_recall
      process_recap
      process_borrow_direct

      # if !recap && !recall && !bd !(a1 & a2).empty?
      if (service_types & ['bd', 'recap', 'recall', 'on_shelf']).empty?
        @services << Requests::Generic.new(self)
        success_messages << I18n.t('requests.submit.success')
      end

      service_types.each do |type|
        success_messages << I18n.t("requests.submit.#{type}_success") unless ['bd', 'recap_no_items'].include? type
      end
      @services
    end

    def service_errors
      return [] if @services.blank?
      @services.map(&:errors).flatten
    end

    private

      def process_hold
        return unless service_types.include? 'on_shelf'
        @services << Requests::HoldItem.new(self)
      end

      def process_recall
        return unless service_types.include? 'recall'
        @services << Requests::Recall.new(self)
      end

      def process_recap
        return unless service_types.include? 'recap'
        @services << if user['user_barcode'] == 'ACCESS'
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
  end
end
