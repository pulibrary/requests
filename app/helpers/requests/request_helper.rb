module Requests
  module RequestHelper
    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end

    def current_user_status
      ## Expect that the host app can provide you a devise current_user object
      if !current_user.nil? && current_user.provider == 'cas'
        I18n.t('requests.account.pul_auth', current_user_name: current_user.uid)
      elsif !current_user.nil?
        #binding.pry
        I18n.t('requests.account.guest', current_user_name: current_user.uid)
      else
        I18n.t('requests.account.unauthenticated')
      end
    end
  end
end
