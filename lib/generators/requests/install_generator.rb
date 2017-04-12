require 'rails/generators'

module Requests
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    class_option :devise, :type => :boolean, :default => false, :aliases => "-d", :desc => "Use Devise as authentication logic (this is default)."
    desc ''"
    This generator does the following:
    1. Creates a requests_inializer.rb in config/initializers.
    2. Creates a requests.yml populated with usabale default values in config.
    3. Creates a requests.en.yml locale file
    4. Updates .gitignore
    "''

    def requests_initializer
      copy_file 'requests_initializer.rb', 'config/initializers/requests_initializer.rb'
    end

    def bd_initializer
      copy_file 'borrow_direct.rb', 'config/initializers/borrow_direct.rb'
    end

    def requests_config
      copy_file './config/requests.yml', 'config/requests.yml'
    end

    def requests_locales
      copy_file './config/locales/requests.en.yml', 'config/locales/requests.en.yml'
    end

    # no longer need to ignore this, use env variables for overrides when needed.
    # def inject_ignore_request_conf
    #   append_to_file '.gitignore', "\nconfig/requests.yml\n" if File.exist?('.gitignore')
    # end

    def inject_routes
      inject_into_file 'config/routes.rb', after: %(Rails.application.routes.draw do\n) do
        %(  mount Requests::Engine, at: '/requests'\n)\
      end
    end

    def devise
      #puts "#{options.to_s}"
      #if options[:devise]
      gem 'devise'
      gem "devise-guests", '~> 0.5'
      gem "omniauth-cas"
      Bundler.with_clean_env do
        run "bundle install"
      end
      copy_file './db/migrate/201605022201303_add_columns_to_users.rb', 'db/migrate/201605022201303_add_columns_to_users.rb'
      generate "devise:install"
      generate "devise", 'User'
      generate "devise_guests", 'User'
      #end
      inject_into_file 'app/models/user.rb', before: %(end\n) do
        %(  devise :omniauthable\n)\
      end
      inject_into_file 'config/initializers/devise.rb', after: %(  # ==> OmniAuth\n) do
        "  config.omniauth :cas, host: 'fed.princeton.edu', url: 'https://fed.princeton.edu/cas'\n" \
        "  config.omniauth :barcode\n" \
      end
      inject_into_file 'config/routes.rb', after: %(  devise_for :users) do 
        %(, :controllers => { omniauth_callbacks: "users/omniauth_callbacks", sessions: 'sessions' }, skip: [:passwords, :registration])
      end
      copy_file './app/controllers/users/omniauth_callbacks_controller.rb', 'app/controllers/users/omniauth_callbacks_controller.rb'
      copy_file './lib/omniauth/strategies/omniauth-barcode.rb', 'lib/omniauth/strategies/omniauth-barcode.rb'
      inject_into_file 'config/application.rb', before: %(  end\n) do
        %(    require Rails.root.join('lib/omniauth/strategies/omniauth-barcode')\n)
      end
      inject_into_file 'app/controllers/application_controller.rb', before: %(end\n) do
        "  def after_sign_in_path_for(_resource)\n" \
        "    request.env['omniauth.origin']\n" \
        "  end\n" \
      end
      inject_into_file 'app/models/user.rb', before: %(end\n) do
      "  def self.from_cas(access_token)\n" \
      "    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|\n" \
      "      user.uid = access_token.uid\n" \
      "      user.username = access_token.uid\n" \
      '      user.email = "#{access_token.uid}@princeton.edu"' \
      "\n      user.password = SecureRandom.urlsafe_base64\n" \
      "      user.provider = access_token.provider\n" \
      "    end\n" \
      "  end\n" \
      "  def self.from_barcode(access_token)\n" \
      "    User.where(provider: access_token.provider, uid: access_token.uid,\n" \
      "             username: access_token.info.last_name).first_or_initialize do |user|\n" \
      "      user.uid = access_token.uid\n" \
      "      user.username = access_token.info.last_name\n" \
      "      user.email = access_token.uid\n" \
      "      user.password = SecureRandom.urlsafe_base64\n" \
      "      user.provider = access_token.provider\n" \
      "    end\n" \
      "  end\n" \
      end
    end
  end
end