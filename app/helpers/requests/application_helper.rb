module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end

    def show_service_options requestable
      content_tag(:ul, class: "service-list") do
        requestable.services.each do |service|
          concat content_tag(:li, "#{service}", class: "service-item")
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
          locs = ["Choose an Option"] + locs.sort
          select_tag "requestable[][pickup]", options_for_select(locs)
        else
          hidden = hidden_field_tag "requestable[][pickup]", "", value: "#{locs[0]}"
          hidden + locs[0]
        end
      end
    end

    def hidden_fields_item requestable
      hidden = hidden_field_tag "requestable[][bibid]", "", value: "#{requestable.bib[:id]}"
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}"
      hidden += hidden_field_tag "requestable[][location_code]", "", value: "#{requestable.item["location"]}"
      unless requestable.item["barcode"].nil?
        hidden += hidden_field_tag "requestable[][barcode]", "", value: "#{requestable.item["barcode"]}"
        hidden += hidden_field_tag "requestable[][id]", "", value: "#{requestable.item["id"]}"
      end
      unless requestable.item["enum"].nil?
        hidden += hidden_field_tag "requestable[][enum]", "", value: "#{requestable.item["enum"]}"
        hidden += hidden_field_tag "requestable[][copy_number]", "", value: "#{requestable.item["copy_number"]}"
      end
      hidden += hidden_field_tag "requestable[][status]", "", value: "#{requestable.item["status"]}"
      hidden
    end

    def hidden_fields_holding requestable
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: "#{requestable.holding.keys[0]}"
      hidden
    end
  end
end
