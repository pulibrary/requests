lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "requests/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "requests"
  s.version     = Requests::VERSION
  s.authors     = ["Kevin Reiss"]
  s.email       = ["kevin.reiss@gmail.com"]
  s.homepage    = "http://github.com/pulibrary/requests"
  s.summary     = "Requests @ PUL"
  s.description = "Fulfillment Options for Princeton University Library."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = '~> 2.6'

  s.add_dependency 'devise'
  s.add_dependency 'rails', '~> 5.2.4'
  s.add_dependency 'bootstrap'
  s.add_dependency 'friendly_id', '~> 5.1.0'
  s.add_dependency 'yaml_db', '~> 0.7.0'
  s.add_dependency 'simple_form'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday-encode_xml'
  s.add_dependency 'borrow_direct', '~> 1.2.0'
  s.add_dependency 'lcsort'
  s.add_dependency 'email_validator'
  s.add_dependency 'cobravsmongoose', '~> 0.0.2'
  s.add_dependency 'openurl', '~> 1.0'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-datatables'
  s.add_dependency 'net-ldap'
  s.add_dependency 'alma'

  s.add_development_dependency 'bixby', '~> 2.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'engine_cart', '~> 2.1'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker', '~> 1.9'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'webdrivers'
  s.add_development_dependency 'webmock'
  s.add_development_dependency "vcr"
  s.add_development_dependency 'rubocop-rspec', '~> 1.22'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'puma'
end
