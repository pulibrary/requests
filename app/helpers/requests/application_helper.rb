module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end

    def service_options requestable
      content_tag(:ul, class: "service-list") do
        requestable.services.each do |service|
          concat content_tag(:li, "#{service}", class: "service-item")
        end
      end
    end

    def pickup_choices requestable
      locs = []
      requestable.pickup_locations.each do |location|
        locs << location[:label]
      end
      select_tag "holding[#{requestable.holding.keys.first}]pickup_location", options_for_select(locs)
    end
  end
end
