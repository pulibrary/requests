require 'rails/generators'

module Requests
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc ''"
    This generator does the following:
    1. Creates a requests_inializer in config/initializers.
    2. Creates a requests.yml populated with test values in config.
    "''

    def requests_initializer
      copy_file 'requests_initializer.rb', 'config/initializers/requests_initializer.rb'
    end

    def requests_config
      copy_file './config/requests.yml', 'config/requests.yml'
    end

    def inject_ignore_request_conf
      insert_into_file '.gitignore', :after => '/tmp' do <<EOF

config/config.yml
EOF
      end
    end
  end
end