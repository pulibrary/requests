module Requests
  module RequestHelper
    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end

    def current_user_status current_user
      ## Expect that the host app can provide you a devise current_user object
      if current_user.provider == 'cas'
        I18n.t('requests.account.pul_auth', current_user_name: current_user.uid)
      elsif current_user.guest == true
        #binding.pry
        link_to I18n.t('requests.account.guest'), '/users/sign_in' #, current_user_name: current_user.uid)
      else
        I18n.t('requests.account.unauthenticated')
      end
    end

    def render_mfhd_message requestable_list
      mfhd_services = []
      requestable_list.each do |requestable|
        requestable.services.each do |service|
          mfhd_services << service
        end
      end
      mfhd_services.uniq!
      if mfhd_services.include? 'paging'
        I18n.t('requests.paging.message')
      end
    end
  end
end
