require 'rails/generators'
require 'rails/generators/migration'

class TestAppGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root "../../spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application
  def install_engine
    generate 'requests:install', '-f'
  end

  def comment_out_sdoc
    gsub_file "Gemfile",
              "gem 'sdoc', '~> 0.4.0', group: :doc", ""
  end

  def run_migrations
    rake 'requests:install:migrations'
    rake "db:migrate"
    #rake "db:migrate RAILS_ENV=test"
  end
end
