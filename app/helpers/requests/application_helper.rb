module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
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
      if requestable.charged?
        link_to 'Check Available Request Options', "https://library.princeton.edu/requests/#{requestable.bib[:id]}", class: 'btn btn-primary'
      elsif requestable.aeon?
        link_to 'Request to View in Reading Room', "#{Requests.config[:aeon_base]}#{requestable.params.to_query}", class: 'btn btn-primary'
      elsif requestable.traceable?
        content_tag(:div) do
          concat link_to 'Where to find it', requestable.stackmap_url
          concat content_tag(:span, I18n.t("requests.trace.brief_msg").html_safe, class: 'service-item')
        end
      else
        unless requestable.services.include? 'recap_edd'
        #unless !(requestable.services && ['recap','recap_edd']).empty?
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
        else
          brief_msg = I18n.t("requests.paging.brief_msg")
        end
        concat content_tag(:li, brief_msg.html_safe, class: "service-item text-muted")
      end
    end

    def hidden_service_options requestable
      if(requestable.services.include? 'annexa')
        request_input('annexa')
      elsif(requestable.services.include? 'annexb')
        request_input('annexb')
      elsif(requestable.services.include? 'paging')
        request_input('paging')
      elsif(requestable.services.include? 'in_process')
        request_input('in_process')
      elsif(requestable.services.include? 'on_order')
        request_input('on_order')
      elsif(requestable.services.include? 'recap_edd' and requestable.services.include? 'recap')
        recap_radio_button_group requestable
      elsif(requestable.services.include? 'recap')
        #request_input('recap')
        recap_print_only_input requestable
      elsif(requestable.services.include? 'trace')
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
      else
        request_input('paging')
      end
    end

    def recap_print_only_input requestable
      content_tag(:fieldset, class: 'recap--print', id: "recap_group_#{requestable.item[:id]}") do
        concat hidden_field_tag "requestable[][type]", "", value: 'recap'
        concat hidden_field_tag "requestable[][delivery_mode_#{requestable.item[:id]}]", "print"
      end
    end

    def enum_copy_display item
      display = ""
      unless item[:enum].nil?
        display += item[:enum]
      end
      if !item[:enum].nil? && !item[:copy_number].nil?
        display += " "
      end
      unless item[:copy_number].nil? || item[:copy_number] == 0 || item[:copy_number] == 1
        display += "Copy #{item[:copy_number]}"
      end
      display
    end

    def request_input type
      hidden_field_tag "requestable[][type]", "", value: type
    end

    def pickup_choices requestable, default_pickups
      unless requestable.pickup_locations.nil? || requestable.charged? # || (requestable.services & self.default_pickup_services).empty?
        class_list = "well collapse in request--print"
        if requestable.services.include?('recap_edd')
            class_list = "well collapse request--print"
        end
        content_tag(:div, id: "fields-print__#{requestable.item['id']}", class: class_list) do
            locs = self.available_pickups(requestable, default_pickups)
            if(locs.size > 1)
               concat select_tag "requestable[][pickup]", options_for_select(locs.map { |loc| [loc[:label], loc[:gfa_code]] }), prompt: I18n.t("requests.default.pickup_placeholder")
            else
              hidden = hidden_field_tag "requestable[][pickup]", "", value: "#{locs[0][:gfa_code]}"
              hidden + locs[0][:label]
            end
        end
      end
    end

    def available_pickups requestable, default_pickups
      locs = []
      if !(requestable.services & self.default_pickup_services).empty?
        locs = default_pickups
      elsif(requestable.services.include? 'trace')
        locs = default_pickups
      else
        requestable.pickup_locations.each do |location|
          locs << { label: location[:label], gfa_code: location[:gfa_pickup] }
        end
      end
      locs
    end

    def default_pickup_services
      ["on_order", "in_process"]
    end

    def pickup_choices_fill_in requestable
      locs = []
      requestable.pickup_locations.each do |location|
        locs << { label: location[:label], gfa_code: location[:gfa_pickup] }
      end
      if(locs.size > 1)
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
      hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.item["location"]}", id: "requestable_location_#{requestable.item['id']}"
      hidden += hidden_field_tag "requestable[][item_id]", "", value: "#{requestable.item["id"]}", id: "requestable_item_id_#{requestable.item['id']}"
      unless requestable.item["barcode"].nil?
        hidden += hidden_field_tag "requestable[][barcode]", "", value: "#{requestable.item["barcode"]}", id: "requestable_barcode_#{requestable.item['id']}"
      end
      unless requestable.item["enum"].nil?
        hidden += hidden_field_tag "requestable[][enum]", "", value: "#{requestable.item["enum"]}", id: "requestable_enum_#{requestable.item['id']}"
      end
      hidden += hidden_field_tag "requestable[][copy_number]", "", value: "#{requestable.item["copy_number"]}", id: "requestable_copy_number_#{requestable.item['id']}"
      hidden += hidden_field_tag "requestable[][status]", "", value: "#{requestable.item["status"]}", id: "requestable_status_#{requestable.item['id']}"
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

    def format_brief_record_display params
      content_tag(:dl, class: "dl-horizontal") do
        params.each do |key, value|
          unless value.nil?
            concat content_tag(:dt, "#{display_label[key]}")
            concat content_tag(:dd, "#{value.first}")
          end
        end
      end
    end

    def hidden_fields_request request
      hidden_request_tags = ''
      hidden_request_tags += hidden_field_tag "bib[id]", "", value: request.doc[:id]
      request.display_metadata.each do |key, value|
        hidden_request_tags += hidden_field_tag "bib[#{key}]", "", value: value
      end
      hidden_request_tags.html_safe
    end

    def status_label requestable
      if requestable.charged?
        content_tag(:span, 'Not Available', class: "availability--label badge-alert label label-danger")
      else
        content_tag(:span, 'Available', class: "availability--label badge-success label label-success")
      end
    end

    def item_checkbox requestable_list, requestable
      check_box_tag "requestable[][selected]", true, check_box_selected(requestable_list), class: 'request--select', disabled: check_box_disabled(requestable), id: "requestable_selected_#{requestable.item['id']}"
    end

    def check_box_disabled requestable
      if requestable.on_order?
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
        true
      elsif requestable.open? && !requestable.pageable?
        true
      elsif requestable.always_requestable?
        true
      else
        false
      end
    end

    def check_box_selected requestable_list
      if requestable_list.size == 1
        if requestable_list.first.charged?
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
        if requestable_list.first.charged?
          if requestable_list.first.annexa?
            false
          elsif requestable_list.first.annexb?
            false
          elsif requestable_list.first.pageable_loc?
            false
          else
            true
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
        unless((requestable.services & self.submitable).empty?)
          submitable = nil
        end
      end
      submitable
    end

    def submitable
      ['in_process', 'on_order', 'annexa', 'annexb', 'recap', 'recap_edd', 'paging']
    end

    def submit_message requestable_list
      single_item = "Request this Item"
      multi_item = "Request Selected Items"
      no_item = "No Items Available"
      trace = "Trace this item"
      if requestable_list.size == 1
        if requestable_list.first.charged?
          if requestable_list.first.annexa?
            multi_item
          elsif requestable_list.first.annexb?
            multi_item
          elsif requestable_list.first.pageable_loc?
            multi_item
          else
            no_item
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
  end
end
