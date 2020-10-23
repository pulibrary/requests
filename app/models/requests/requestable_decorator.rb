module Requests
  class RequestableDecorator
    delegate :system_id, :aeon_mapped_params, :services, :charged?, :annexa?, :annexb?, :pageable_loc?, :traceable?, :on_reserve?,
             :ask_me?, :etas?, :etas_limited_access, :aeon_request_url, :location, :temp_loc?, :call_number, :eligible_to_pickup?,
             :in_library_use_only?, :preferred_request_id, :bib, :circulates?, :open_libraries, :item_data?, :recap_edd?, :user_barcode,
             :holding, :item_location_code, :item?, :item, :scsb?, :status_label, :use_restriction?, :library_code, :enum_value,
             :cron_value, :illiad_request_parameters, :location_label, :online?, :aeon?, :borrow_direct?, :patron,
             :ill_eligible?, :scsb_in_library_use?, :pick_up_locations, :on_shelf?, :pending?, :recap?, :illiad_request_url,
             :campus_authorized, :on_order?, :urls, :in_process?, :voyager_managed?, :covid_trained?, to: :requestable
    delegate :content_tag, :hidden_field_tag, :concat, to: :view_context

    alias bib_id system_id

    attr_reader :requestable, :view_context
    def initialize(requestable, view_context)
      @requestable = requestable
      @view_context = view_context
    end

    def digitize?
      (item_data? || !circulates?) && (on_shelf_edd? || (recap_edd? && !scsb_in_library_use?)) && !request_status?
    end

    def fill_in_digitize?
      !item_data? || digitize?
    end

    def pick_up?
      return false if etas? || !eligible_to_pickup?
      item_data? && (on_shelf? || recap? || annexa?) && circulates? && !in_library_use_only? && !scsb_in_library_use? && !request_status?
    end

    def fill_in_pick_up?
      return false if user_barcode.blank? || !covid_trained?
      !item_data? || pick_up?
    end

    def request?
      return false if user_barcode.blank? || !covid_trained?
      request_status?
    end

    def request_status?
      on_order? || in_process? || traceable? || aeon? || borrow_direct? || ill_eligible? || services.empty?
    end

    def help_me?
      ask_me? || (!available_for_digitizing? && !aeon?) || (request_status? && !request?)
    end

    def available_for_appointment?
      !circulates? && !recap? && !charged? && !aeon? && !etas? && campus_authorized
    end

    def will_submit_via_form?
      return false if recap? || recap_edd?
      digitize? || pick_up? || scsb_in_library_use? || (ill_eligible? && patron.covid_trained?) || ((on_order? || in_process? || traceable?) && user_barcode.present?)
    end

    def available_for_digitizing?
      open_libraries.include?(location[:library][:code])
    end

    def on_shelf_edd?
      services.include?('on_shelf_edd')
    end

    def create_fill_in_requestable
      fill_in_req = Requestable.new(bib: bib, holding: holding, item: nil, location: location, patron: patron)
      fill_in_req.services = services
      RequestableDecorator.new(fill_in_req, view_context)
    end

    def libcal_url
      return unless available_for_appointment?
      Libcal.url(location['library']['code'])
    end

    def status_badge
      css_class = if requestable.charged?
                    "badge-danger"
                  else
                    "badge-success"
                  end
      content_tag(:span, requestable.status_label, class: "availability--label badge #{css_class}")
    end
  end
end
