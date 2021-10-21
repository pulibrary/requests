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
      @patron = patron
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
      @bd = params[:bd] # TODO: can we remove this?
      @services = []
      @success_messages = []
      @duplicate = false
    end

    attr_reader :patron, :success_messages

    def email
      @patron.active_email
    end

    def source
      @patron.source
    end

    def user_name
      @patron.netid
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
      @patron.barcode
    end

    attr_reader :bib

    def id
      @bib[:id]
    end

    def partner_item?(item)
      Requests::Config[:recap_partner_locations].keys.include? item["location_code"]
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
      process_hold
      process_recall
      process_recap
      process_borrow_direct
      process_digitize
      process_help_me
      process_clancy

      # if !recap && !recall && !bd !(a1 & a2).empty?
      if generic_service_only?
        @services << Requests::Generic.new(self)
        success_messages << I18n.t('requests.submit.success')
      end

      @success_messages = generate_success_messages(@success_messages)

      send_mail if service_errors.blank? && !@duplicate

      @services
    end

    def service_errors
      return [] if @services.blank?
      @services.map(&:errors).flatten
    end

    def pick_up_location
      Requests::BibdataService.delivery_locations[items.first["pick_up"]]["library"]
    end

    def access_only?
      user_barcode == 'ACCESS'
    end

    def marquand?
      items.first["holding_library"] == 'marquand'
    end

    def edd?(item)
      # return false if item["type"] == "digitize_fill_in"
      delivery_mode = delivery_mode(item)
      delivery_mode.present? && delivery_mode == "edd"
    end

    private

      # rubocop:disable Metrics/MethodLength
      def categorize_by_delivery_and_location(item)
        library_code = item["library_code"]
        if recap_no_items?(item)
          item["type"] = "recap_no_items"
        elsif off_site?(library_code)
          item["type"] = library_code
          item["type"] += "_edd" if edd?(item)
          item["type"] += "_in_library" if in_library?(item)
        elsif item["type"] == "paging"
          item["type"] = "digitize" if edd?(item)
        elsif print?(item) && library_code == 'annex'
          item["type"] = "annex"
        elsif edd?(item) && library_code.present?
          item["type"] = "digitize"
        elsif print?(item) && library_code.present?
          item["type"] = "on_shelf"
        end
        item
      end
      # rubocop:enable Metrics/MethodLength

      def in_library?(item)
        # return false if item["type"] == "digitize_fill_in"
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "in_library"
      end

      def recap_no_items?(item)
        item["library_code"] == 'recap' && (item["type"] == "digitize_fill_in" || item["type"] == "recap_no_items")
      end

      def off_site?(library_code)
        library_code == 'recap' || library_code == 'marquand' || library_code == 'clancy' || library_code == 'recap_marquand' || library_code == 'clancy_unavailable'
      end

      def print?(item)
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "print"
      end

      def delivery_mode(item)
        item["delivery_mode_#{item['item_id']}"]
      end

      def process_hold
        return unless service_types.include?('on_shelf') || service_types.include?('marquand_in_library') || service_types.include?('annex')

        hold = if service_types.include? 'on_shelf'
                 Requests::HoldItem.new(self)
               elsif service_types.include? 'marquand_in_library'
                 Requests::HoldItem.new(self, service_type: 'marquand_in_library')
               elsif service_types.include? 'annex'
                 Requests::HoldItem.new(self, service_type: 'annex')
               end
        hold.handle
        @duplicate = hold.duplicate?
        @services << hold
      end

      def process_recall
        return unless service_types.include? 'recall'
        @services << Requests::Recall.new(self)
      end

      def process_digitize
        return if (['digitize', 'marquand_edd', 'clancy_unavailable_edd'] & service_types).blank?
        @services << if access_only?
                       # Access users cannot use illiad service directly
                       Requests::Generic.new(self)
                     else
                       Requests::DigitizeItem.new(self)
                     end
      end

      def process_recap
        return if (['recap', 'recap_edd', 'recap_in_library', 'recap_marquand_in_library', 'recap_marquand_edd'] & service_types).blank?
        @services << if access_only?
                       # Access users cannot use recap service directly
                       Requests::Generic.new(self)
                     else
                       Requests::Recap.new(self)
                     end
      end

      def process_clancy
        return if (['clancy_in_library', 'clancy_edd'] & service_types).blank?
        clancy_services = []
        clancy_services << Requests::Clancy.new(self) if service_types.include?('clancy_in_library')
        clancy_services << Requests::ClancyEdd.new(self) if service_types.include?('clancy_edd')
        clancy_services.each(&:handle)
        @services += clancy_services
      end

      def process_help_me
        return unless service_types.include?('help_me')
        @services << if access_only?
                       # Access users cannot use illiad directly
                       Requests::Generic.new(self)
                     else
                       help_me = Requests::HelpMe.new(self)
                       help_me.handle
                       help_me
                     end
      end

      def process_borrow_direct
        return unless service_types.include?('bd') || service_types.include?('ill')
        bd_request = Requests::BorrowDirect.new(self)
        bd_request.handle
        @services << bd_request
        return if bd_request.errors.present?
        if bd_request.handled_by == "borrow_direct"
          success_messages << "#{I18n.t('requests.submit.bd_success')} Your request number is #{bd_request.sent[0][:request_number]}"
        else
          Requests::RequestMailer.send("interlibrary_loan_confirmation", self).deliver_now
          success_messages << I18n.t('requests.submit.interlibrary_loan_success')
        end
      end

      def generic_service?(type)
        !non_generic_services.include?(type)
      end

      def generic_service_only?
        (service_types & non_generic_services).empty? && (!service_types.include?('bd') && !service_types.include?('ill'))
      end

      def non_generic_services
        ['recap', 'recall', 'on_shelf', 'digitize', 'help_me', 'clancy_in_library', 'clancy_edd', 'marquand_edd', 'marquand_in_library']
      end

      def generate_success_messages(success_messages)
        if @duplicate
          success_messages << I18n.t("requests.submit.duplicate")
        else
          service_types.each do |type|
            success_messages << I18n.t("requests.submit.#{type}_success") unless generic_service?(type)
          end
        end
        success_messages
      end

      def send_mail
        mail_service_types = service_types.reject { |type| ['bd', 'ill'].include? type } # emails already sent for ill and bd
        mail_service_types.each do |type|
          Requests::RequestMailer.send("#{type}_email", self).deliver_now unless type == 'recap_edd'
          Requests::RequestMailer.send("#{type}_confirmation", self).deliver_now if type != 'recall'
          Requests::RequestMailer.send("scsb_recall_email", self).deliver_now if type == 'recall' && items_held_by_partner?
        end
      end

      def items_held_by_partner?
        @items.select { |item| partner_item?(item) }.size.positive?
      end
  end
end
