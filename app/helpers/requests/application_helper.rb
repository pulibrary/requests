module Requests
  module ApplicationHelper
    def sanitize(str)
      if str.is_a? String
        str.gsub(/[^A-Za-z0-9@\-_\.]/, '')
      end
      str
    end

    def format_email(email)
      unless email.nil?
        email.downcase
      end
    end

    def format_label(key)
      label = key.to_s
      human_label = label.gsub(/_/, ' ')
      formatted = human_label.split.map(&:capitalize).join(' ')
      formatted
    end

    def error_key_format(key)
      keys_to_ignore = ['items']
      unless keys_to_ignore.include? key.to_s
        format_label(key)
      end
    end

    # array of error_keys
    def guest_user_error?(error_keys)
      user_errors = [:email, :user_name, :user_barcode]
      error_keys.any? { |item| user_errors.include? item }
    end

    def show_service_options requestable
      if requestable.services.empty?
        content_tag(:div, I18n.t("requests.no_services.brief_msg").html_safe, class: 'service-item')
      elsif requestable.charged? && !requestable.aeon?
        render partial: 'checked_out_options', locals: { requestable: requestable }
      elsif requestable.aeon? && requestable.voyager_managed?
        link_to 'Request to View in Reading Room', requestable.aeon_request_url(@request.ctx), class: 'btn btn-primary'
      elsif requestable.aeon?
        link_to 'Request to View in Reading Room', "#{Requests.config[:aeon_base]}?#{requestable.aeon_mapped_params.to_query}", class: 'btn btn-primary'
      elsif requestable.on_shelf?
        content_tag(:div) do
          concat link_to 'Where to find it', requestable.map_url
          if requestable.traceable?
            concat content_tag(:div, I18n.t("requests.trace.brief_msg").html_safe, class: 'service-item')
          end
        end
      else
        unless requestable.services.include? 'recap_edd'
        # unless !(requestable.services && ['recap','recap_edd']).empty?
          content_tag(:ul, class: "service-list") do
            requestable.services.each do |service|
              brief_msg = I18n.t("requests.#{service}.brief_msg")
              concat content_tag(:li, brief_msg.html_safe, class: "service-item text-muted")
            end
          end
        end
      end
    end

    def show_service_options_fill_in requestable
      content_tag(:ul, class: "service-list") do
        if requestable.annexa?
          brief_msg = I18n.t("requests.annexa.brief_msg")
        elsif requestable.annexb?
          brief_msg = I18n.t("requests.annexb.brief_msg")
        elsif requestable.preservation?
          brief_msg = I18n.t("requests.pres.brief_msg")
        elsif requestable.services.include? 'recap_no_items'
          brief_msg = I18n.t("requests.recap_no_items.brief_msg")
        else
          brief_msg = I18n.t("requests.paging.brief_msg")
        end
        concat content_tag(:li, brief_msg.html_safe, class: "service-item text-muted")
      end
    end

    def hidden_service_options requestable
      if requestable.services.include? 'annexa'
        request_input('annexa')
      elsif requestable.services.include? 'bd'
        request_input('bd')
      elsif requestable.services.include? 'annexb'
        request_input('annexb')
      elsif requestable.services.include? 'pres'
        request_input('pres')
      elsif requestable.services.include? 'ppl'
        request_input('ppl')
      elsif requestable.services.include? 'paging'
        request_input('paging')
      elsif requestable.services.include? 'in_process'
        request_input('in_process')
      elsif requestable.services.include? 'on_order'
        request_input('on_order')
      elsif requestable.services.include? 'recap_edd' and requestable.services.include? 'recap'
        recap_radio_button_group requestable
      elsif requestable.services.include? 'recap'
        # request_input('recap')
        recap_print_only_input requestable
      elsif requestable.services.include? 'trace'
        request_input('trace')
      else
        nil
      end
    end

    # only requestable services that support "user-supplied volume info"
    def hidden_service_options_fill_in requestable
      if requestable.annexa?
        request_input('annexa')
      elsif requestable.annexb?
        request_input('annexb')
      elsif requestable.services.include? 'recap_no_items'
        request_input('recap_no_items')
      else
        request_input('paging')
      end
    end

    def recap_print_only_input requestable
      # id = requestable.item? ? requestable.item['id'] : requestable.holding['id']
      content_tag(:fieldset, class: 'recap--print', id: "recap_group_#{requestable.preferred_request_id}") do
        concat hidden_field_tag "requestable[][type]", "", value: 'recap'
        concat hidden_field_tag "requestable[][delivery_mode_#{requestable.preferred_request_id}]", "print"
      end
    end

    def enum_copy_display item
      display = ""
      unless item[:enum_display].nil?
        display += item[:enum_display]
      end
      if !item[:enum_display].nil? && !item[:copy_number].nil?
        display += " "
      end
      # For scsb materials
      if item[:enumeration]
        display += item[:enumeration]
      end
      unless item[:copy_number].nil? || item[:copy_number] == 0 || item[:copy_number] == 1 || item[:copy_number] == '1'
        display += "Copy #{item[:copy_number]}"
      end
      display
    end

    def request_input type
      hidden_field_tag "requestable[][type]", "", value: type
    end

    def gfa_lookup lib_code
      if lib_code == "firestone"
        gfa_code = "PA"
      else
        lib = Requests::BibdataService.delivery_locations.select { |_key, hash| hash["library"]["code"] == lib_code }
        gfa_code = lib.keys.first.to_s
      end
    end

    # move this to requestable object
    # Default pickups should be available
    def pickup_choices requestable, default_pickups
      unless requestable.charged? || (requestable.services.include? 'on_shelf') || requestable.services.empty? # requestable.pickup_locations.nil?
        class_list = "well collapse in request--print"
        if requestable.services.include?('recap_edd')
          class_list = "well collapse request--print"
        end
        # id = requestable.item? ? requestable.item['id'] : requestable.holding['id']
        content_tag(:div, id: "fields-print__#{requestable.preferred_request_id}", class: class_list) do
          if requestable.pending?
            if requestable.location[:holding_library].blank?
              locs = [{ label: requestable.location[:library][:label], gfa_code: gfa_lookup(requestable.location[:library][:code]), staff_only: false }]
            else
              locs = [{ label: requestable.location[:holding_library][:label], gfa_code: gfa_lookup(requestable.location[:holding_library][:code]), staff_only: false }]
            end
          else
            locs = self.available_pickups(requestable, default_pickups)
          end
          if locs.size > 1
            concat select_tag "requestable[][pickup]", options_for_select(locs.map { |loc| [loc[:label], loc[:gfa_code]] }), prompt: I18n.t("requests.default.pickup_placeholder")
          else
            style = requestable.charged? ? 'display:none;margin-top:10px;' : ''
            name = requestable.charged? ? 'updated_later' : 'requestable[][pickup]'
            hidden = hidden_field_tag "#{name}", "", value: "#{locs[0][:gfa_code]}", class: 'single-pickup-hidden'
            label = label_tag "#{name}", "Pickup location: #{locs[0][:label]}", class: 'single-pickup', style: "#{style}"
            hidden + label
          end
        end
      end
    end

    def available_pickups requestable, default_pickups
      locs = []
      if requestable.services.include? 'trace'
        locs = default_pickups
      elsif requestable.pickup_locations.nil?
        locs = default_pickups
      else
        requestable.pickup_locations.each do |location|
          locs << { label: location[:label], gfa_code: location[:gfa_pickup], staff_only: location[:staff_only] }
        end
      end
      locs
    end

    def pickup_choices_fill_in requestable, default_pickups
      locs = []
      if requestable.pickup_locations.nil? || requestable.location['delivery_locations'].empty?
        locs = self.available_pickups(requestable, default_pickups)
      else
        requestable.pickup_locations.each do |location|
          locs << { label: location[:label], gfa_code: location[:gfa_pickup] }
        end
      end
      if locs.size > 1
        select_tag "requestable[][pickup]", options_for_select(locs.map { |loc| [loc[:label], loc[:gfa_code]] }), prompt: I18n.t("requests.default.pickup_placeholder")
      else
        hidden = hidden_field_tag "requestable[][pickup]", "", value: "#{locs[0][:gfa_code]}"
        hidden + locs[0][:label]
      end
    end

    def hidden_fields_mfhd mfhd
      hidden = ""
      unless mfhd["call_number"].nil?
        hidden += hidden_field_tag "mfhd[][call_number]", "", value: "#{mfhd['call_number']}"
      end
      unless mfhd["location"].nil?
        hidden += hidden_field_tag "mfhd[][location]", "", value: "#{mfhd["location"]}"
      end
      hidden += hidden_field_tag "mfhd[][library]", "", value: "#{mfhd["library"]}"
      hidden.html_safe
    end

    def hidden_fields_item requestable
      hidden = hidden_field_tag "requestable[][bibid]", "", value: "#{requestable.bib[:id]}", id: "requestable_bibid_#{requestable.item['id']}"
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}", id: "requestable_mfhd_#{requestable.item['id']}"
      unless requestable.holding.first[1]["call_number"].nil?
        hidden += hidden_field_tag "requestable[][call_number]", "", value: "#{requestable.holding.first[1]['call_number']}", id: "requestable_call_number_#{requestable.item['id']}"
      end
      if requestable.item["location"].nil?
        hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.location['code']}", id: "requestable_location_#{requestable.item['id']}"
      else
        hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.item["location"]}", id: "requestable_location_#{requestable.item['id']}"
      end
      hidden += hidden_field_tag "requestable[][item_id]", "", value: "#{requestable.item["id"]}", id: "requestable_item_id_#{requestable.item['id']}"
      unless requestable.item["barcode"].nil?
        hidden += hidden_field_tag "requestable[][barcode]", "", value: "#{requestable.item["barcode"]}", id: "requestable_barcode_#{requestable.item['id']}"
      end
      unless requestable.item["enum"].nil?
        hidden += hidden_field_tag "requestable[][enum]", "", value: "#{requestable.item["enum"]}", id: "requestable_enum_#{requestable.item['id']}"
      end
      unless requestable.item["enumeration"].nil?
        hidden += hidden_field_tag "requestable[][enum]", "", value: "#{requestable.item["enumeration"]}", id: "requestable_enum_#{requestable.item['id']}"
      end
      hidden += hidden_field_tag "requestable[][copy_number]", "", value: "#{requestable.item["copy_number"]}", id: "requestable_copy_number_#{requestable.item['id']}"
      hidden += hidden_field_tag "requestable[][status]", "", value: "#{requestable.item["status"]}", id: "requestable_status_#{requestable.item['id']}"
      if requestable.scsb?
        hidden += hidden_field_tag "requestable[][cgc]", "", value: "#{requestable.item["cgc"]}", id: "requestable_cgc_#{requestable.item['id']}"
        hidden += hidden_field_tag "requestable[][cc]", "", value: "#{requestable.item["collection_code"]}", id: "requestable_collection_code_#{requestable.item['id']}"
        hidden += hidden_field_tag "requestable[][use_statement]", "", value: "#{requestable.item["use_statement"]}", id: "requestable_use_statement_#{requestable.item['id']}"
      end
      unless requestable.item["scsb_status"].nil?
        hidden += hidden_field_tag "requestable[][scsb_status]", "", value: "#{requestable.item["scsb_status"]}", id: "requestable_scsb_status_#{requestable.item['id']}"
      end
      hidden
    end

    def hidden_fields_holding requestable
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}", id: "requestable_mfhd_#{requestable.holding.keys[0]}"
      unless requestable.holding.first[1]["call_number"].nil?
        hidden += hidden_field_tag "requestable[][call_number]", "", value: "#{requestable.holding.first[1]['call_number']}", id: "requestable_call_number_#{requestable.holding.keys[0]}"
      end
      hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.holding.first[1]['location_code']}", id: "requestable_location_code_#{requestable.holding.keys[0]}"
      hidden += hidden_field_tag "requestable[][location]", "", value: "#{requestable.holding.first[1]["location"]}", id: "requestable_location_#{requestable.holding.keys[0]}"
      hidden
    end

    def format_brief_record_display request
      params = request.display_metadata
      content_tag(:dl, class: "dl-horizontal") do
        params.each do |key, value|
          unless value.nil?
            concat content_tag(:dt, "#{display_label[key]}")
            concat content_tag(:dd, "#{value.first}", lang: "#{request.get_language}", id: "#{display_label[key].gsub(/[^0-9a-z ]/i, '').downcase}")
          end
        end
      end
    end

    def hidden_fields_borrow_direct request
      hidden_bd_tags = ''
      hidden_bd_tags += hidden_field_tag 'bd[auth_id]', '', value: ''
      hidden_bd_tags += hidden_field_tag 'bd[query_params]', '', value: request.isbn_numbers.first
      hidden_bd_tags.html_safe
    end

    def isbn_string array_of_isbns
      array_of_isbns.join(',')
    end

    def hidden_fields_request request
      hidden_request_tags = ''
      hidden_request_tags += hidden_field_tag "bib[id]", "", value: request.doc[:id]
      request.display_metadata.each do |key, value|
        hidden_request_tags += hidden_field_tag "bib[#{key}]", "", value: value
      end
      hidden_request_tags.html_safe
    end

    def suppress_login request
      suppress_login = false
      if request.mfhd.present?
        not_aeon = request.sorted_requestable[request.mfhd].select { |req| !req.aeon? }
        if not_aeon.empty?
          suppress_login = true
        end
      end
      suppress_login
    end

    def status_label requestable
      if requestable.charged?
        content_tag(:span, 'Not Available', class: "availability--label badge-alert label label-danger")
      else
        content_tag(:span, 'Available', class: "availability--label badge-success label label-success")
      end
    end

    def item_checkbox requestable_list, requestable
      check_box_tag "requestable[][selected]", true, check_box_selected(requestable_list), class: 'request--select', disabled: check_box_disabled(requestable), :aria => { :labelledby => "title enum_#{requestable.preferred_request_id}" }, id: "requestable_selected_#{requestable.preferred_request_id}"
    end

    def check_box_disabled requestable
      if requestable.services.empty?
        true
      elsif requestable.on_reserve?
        true
      elsif requestable.on_order?
        false
      elsif requestable.in_process?
        false
      elsif requestable.traceable?
        false
      elsif requestable.always_requestable? && requestable.recap?
        false
      elsif requestable.aeon?
        true
      elsif requestable.charged?
        # true
        false
      elsif requestable.open? && !requestable.pageable?
        true
      elsif requestable.always_requestable?
        true
      else
        false
      end
    end

    ## If any requetable items have a temp location assume everything at the holding is in a temp loc?
    def current_location_label(mfhd_label, requestable_list)
      location_label = requestable_list.first.location['label'].blank? ? "" : "- #{requestable_list.first.location['label']}"
      if requestable_list.first.temp_loc?
        "#{requestable_list.first.location['library']['label']}#{location_label}"
      else
        mfhd_label
      end
    end

    def check_box_selected requestable_list
      if requestable_list.size == 1
        if requestable_list.first.charged? || requestable_list.first.services.empty?
          false
        else
          true
        end
      else
        false
      end
    end

    def submit_button_disabled requestable_list
      if requestable_list.size == 1
        if requestable_list.first.services.empty?
          true
        elsif requestable_list.first.on_reserve?
          true
        elsif requestable_list.first.services.include? 'on_shelf'
          true
        elsif requestable_list.first.charged?
          if requestable_list.first.annexa?
            false
          elsif requestable_list.first.services.include? 'bd'
            false
          elsif requestable_list.first.annexb?
            false
          elsif requestable_list.first.pageable_loc?
            false
          else
            false
          end
        else
          false
        end
      else
        if has_submitable? requestable_list
          true
        else
          false
        end
      end
    end

    def has_submitable? requestable_list
      submitable = true
      requestable_list.each do |requestable|
        unless (requestable.services & self.submitable).empty?
          submitable = false
        end
      end
      submitable
    end

    def submitable
      ['in_process', 'on_order', 'annexa', 'annexb', 'recap', 'recap_edd', 'paging', 'recall', 'bd', 'recap_no_items']
    end

    def submit_message requestable_list
      single_item = "Request this Item"
      multi_item = "Request Selected Items"
      no_item = "No Items Available"
      trace = "Trace this item"
      if requestable_list.size == 1
        if requestable_list.first.services.empty?
          no_item
        elsif requestable_list.first.charged?
          if requestable_list.first.annexa?
            multi_item
          elsif requestable_list.first.annexb?
            multi_item
          elsif requestable_list.first.pageable_loc?
            multi_item
          else
            single_item # no_item
          end
        else
          if requestable_list.first.annexa?
            multi_item
          elsif requestable_list.first.annexb?
            multi_item
          elsif requestable_list.first.pageable_loc?
            multi_item
          elsif requestable_list.first.traceable?
            trace
          else
            single_item
          end
        end
      else
        multi_item
      end
    end

    # only show the table sort if there are enough items
    # to make it worthwhile
    def show_tablesorter requestable_list
      table_class = ""
      if requestable_list.size > 5
        table_class += "tablesorter"
      end
      table_class
    end

    def display_label
      {
        author: "Author/Artist:",
        title: "Title:",
        date: "Published/Created:",
        id: "Bibliographic ID:",
        mfhd: "Holding ID (mfhd):"
      }.with_indifferent_access
    end

    # def display_language
    #   {
    #     language: "Language:"
    #   }.with_indifferent_access
    # end

    def display_status requestable
      unless requestable.item.nil?
        content_tag(:span, requestable.item['status'])
      end
    end

    def system_status_label requestable
      unless requestable.item.key? :scsb_status
        content_tag(:div, requestable.item[:status])
      end
    end

    def display_urls requestable
      content_tag :ol do
        requestable.urls.each do |key, value|
          unless key == 'iiif_manifest_paths'
            value.reverse!
            concat content_tag(:li, link_to(value.join(": "), key), :class => 'link')
          end
        end
      end
    end
  end
end
