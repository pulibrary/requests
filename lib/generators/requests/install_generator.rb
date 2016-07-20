require 'rails/generators'

module Requests
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    class_option :devise, :type => :boolean, :default => false, :aliases => "-d", :desc => "Use Devise as authentication logic (this is default)."
    desc ''"
    This generator does the following:
    1. Creates a requests_inializer in config/initializers.
    2. Creates a requests.yml populated with test values in config.
    3. Creates a requests.en.yml locale file
    4. Updates .gitignore
    "''

    def requests_initializer
      copy_file 'requests_initializer.rb', 'config/initializers/requests_initializer.rb'
    end

    def requests_config
      copy_file './config/requests.yml', 'config/requests.yml'
    end

    def requests_locales
      copy_file './config/locales/requests.en.yml', 'config/locales/requests.en.yml'
    end

    def inject_ignore_request_conf
      append_to_file '.gitignore', "\nconfig/requests.yml\n" if File.exist?('.gitignore')
    end

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
    end
  end
end