require 'rails/generators'
require 'rails/generators/migration'

class TestAppGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root "../../spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application
  def install_engine
    generate 'requests:install',  '-f'
  end
  
  def add_gems
    gem 'bootstrap-sass', '~> 3.3'
    gem 'yaml_db', '~> 0.3.0'
    gem 'borrow_direct', '~> 1.2.0'
    gem 'factory_girl_rails', '~> 4.5.0', group: [:development, :test]
    gem 'faker', '~> 1.4.3', group: [:development, :test]
    gem 'pry-byebug', group: [:development, :test]
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_migrations
    rake 'requests:install:migrations'
    rake "db:migrate"
    #rake "db:migrate RAILS_ENV=test"
  end

  def clean_device_spec
    File.delete 'spec/models/user_spec.rb'
    File.delete 'spec/factories/users.rb'
  end

end
