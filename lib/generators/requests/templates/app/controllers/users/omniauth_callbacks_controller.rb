module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def cas
      @user = User.from_cas(request.env['omniauth.auth'])

      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      return unless is_navigational_format?
      set_flash_message(:notice, :success, kind: 'from Princeton Central Authentication '\
                                                   'Service')
    end

    def barcode
      @user = User.from_barcode(request.env['omniauth.auth'])
      patron = Bibdata.get_patron(@user.uid)
      if patron == false || !last_name_match?(@user.username, patron['last_name']) || !@user.valid?
        flash_validation
        redirect_to new_user_session_path
        set_flash_message(:error, :failure, reason: 'barcode or last name did not match active patron')
      elsif netid_patron?(patron)
        redirect_to new_user_session_path
        flash[:error] = I18n.t('blacklight.login.barcode_netid')
      else
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'with barcode') if is_navigational_format?
      end
    end

    private

      def last_name_match?(username, last_name)
        !last_name.nil? && username.casecmp(last_name).zero?
      end

      def netid_patron?(patron)
        !patron['netid'].nil? && Date.parse(patron['expire_date']) > Time.zone.today
      end

      def flash_validation
        flash[:barcode] = @user.errors[:uid] unless @user.errors[:uid].empty?
        flash[:last_name] = @user.errors[:username] unless @user.errors[:username].empty?
      end
  end
end
