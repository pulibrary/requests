module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end

    def show_service_options requestable
      if requestable.charged?
        link_to 'Check Available Request Options', "https://library.princeton.edu/requests/#{requestable.bib[:id]}", class: 'btn btn-primary'
      else
        content_tag(:ul, class: "service-list") do
          requestable.services.each do |service|
            brief_msg = I18n.t("requests.#{service}.brief_msg")
            concat content_tag(:li, brief_msg.html_safe, class: "service-item")
          end
        end
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
        recap_radio_button_group
      elsif(requestable.services.include? 'recap')
        request_input('recap')
      else
        nil
      end
    end

    def recap_radio_button_group
      radio = radio_button_tag "requestable[][type]", "recap"
      radio += label_tag "requestable_recap", "Print"
      radio += radio_button_tag "requestable[][type]", "recap_edd"
      radio += label_tag "requestable_recap_edd", "Electronic Delivery"
      radio
    end

    def request_input type
      hidden_field_tag "requestable[][type]", "", value: type 
    end

    def pickup_choices requestable
      locs = []
      unless requestable.pickup_locations.nil? || requestable.charged?
        requestable.pickup_locations.each do |location|
          locs << location[:label]
        end
        if(locs.size > 1)
          locs = ["Select Delivery Location"] + locs.sort
          select_tag "requestable[][pickup]", options_for_select(locs)
        else
          hidden = hidden_field_tag "requestable[][pickup]", "", value: "#{locs[0]}"
          hidden + locs[0]
        end
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
        content_tag(:span, 'Not Available', class: "badge-alert")
      else 
        content_tag(:span, 'Available', class: "badge-success")
      end
    end

    def item_checkbox requestable_list, requestable
      check_box_tag "requestable[][selected]", true, check_box_selected(requestable_list), class: 'request--select', disabled: check_box_disabled(requestable), id: "requestable_selected_#{requestable.item['id']}"
    end

    def check_box_disabled requestable
      if requestable.aeon?
        true
      elsif requestable.charged?
        true
      elsif requestable.open? && !requestable.pageable?
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
          true
        else
          false
        end
      else
        false
      end
    end


    def submit_message requestable
      if requestable.size == 1
        if requestable.first.charged?
          "No Items Available"
        else
          "Request this Item"
        end
      else
        "Request Selected Items"
      end
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
