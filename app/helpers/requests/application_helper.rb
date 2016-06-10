module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end

    def show_service_options requestable
      content_tag(:ul, class: "service-list") do
        requestable.services.each do |service|
          brief_msg = I18n.t("requests.#{service}.brief_msg")
          concat content_tag(:li, brief_msg.html_safe, class: "service-item")
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
      unless requestable.pickup_locations.nil?
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
        hidden += hidden_field_tag "requestable[][call_number]", "", value: "#{mfhd["call_number"]}"
      end
      unless mfhd["location"].nil?
        hidden += hidden_field_tag "requestable[][location]", "", value: "#{mfhd["location"]}"
      end
      hidden += hidden_field_tag "requestable[][library]", "", value: "#{mfhd["library"]}"
      hidden.html_safe
    end

    def hidden_fields_item requestable
      hidden = hidden_field_tag "requestable[][bibid]", "", value: "#{requestable.bib[:id]}"
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}"
      hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.item["location"]}"
      hidden += hidden_field_tag "requestable[][item_id]", "", value: "#{requestable.item["id"]}"
      unless requestable.item["barcode"].nil?
        hidden += hidden_field_tag "requestable[][barcode]", "", value: "#{requestable.item["barcode"]}"
      end
      unless requestable.item["enum"].nil?
        hidden += hidden_field_tag "requestable[][enum]", "", value: "#{requestable.item["enum"]}"
      end
      hidden += hidden_field_tag "requestable[][copy_number]", "", value: "#{requestable.item["copy_number"]}"
      hidden += hidden_field_tag "requestable[][status]", "", value: "#{requestable.item["status"]}"
      hidden
    end

    def hidden_fields_holding requestable
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}"
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

    def check_box_selected requestable_list
      if requestable_list.size == 1
        true
      else
        false
      end
    end

    def submit_message requestable
      if requestable.size == 1
        "Request this Item"
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
