module Requests
  module RequestHelper
    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end

    def current_user_status current_user
      ## Expect that the host app can provide you a devise current_user object
      if current_user.provider == 'cas'
        content_tag(:dl, class: "flash_messages-user") do
          content_tag(:div, I18n.t('requests.account.pul_auth', current_user_name: current_user.uid), class: "flash-alert")
        end
      elsif current_user.guest == true
        button_to I18n.t('requests.account.guest'), '/users/auth/cas', class: 'btn btn-primary' #, current_user_name: current_user.uid)
      else
        I18n.t('requests.account.unauthenticated')
      end
    end

    def request_title request
      if request.has_pageable?
        "Library Paging Request"
      else
        "Library Material Request"
      end
    end

    ### FIXME. This should come directly as a sub-property from the request object holding property.
    def render_mfhd_message requestable_list
      mfhd_services = []
      requestable_list.each do |requestable|
        requestable.services.each do |service|
          mfhd_services << service
        end
      end
      mfhd_services.uniq!
      if mfhd_services.include? 'paging'
        content_tag(:div, class: 'flash_mesages-mfhd flash-notice') do
          concat content_tag(:div, I18n.t('requests.paging.status').html_safe)
          concat content_tag(:div, I18n.t('requests.paging.message').html_safe)
        end
      end
    end
  end
end
