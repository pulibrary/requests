# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../.internal_test_app/config/environment', __FILE__)
require 'factory_girl'
require 'webmock/rspec'
require 'rspec/rails'
require 'engine_cart'
require 'database_cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'simplecov'
require 'devise'

WebMock.disable_net_connect!(allow_localhost: false)

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end
SimpleCov.start('rails') do
  add_filter '/lib/generators/requests/install_generator.rb'
  add_filter '/lib/generators/requests/templates/borrow_direct.rb'
  add_filter '/lib/generators/requests/templates/requests_initializer.rb'
  add_filter '/lib/generators/requests/templates/lib/omniauth/strategies/omniauth-barcode.rb'
  add_filter '/lib/generators/requests/templates/app/controllers/users/omniauth_callbacks_controller.rb'
  add_filter '/lib/requests/version.rb'
  add_filter '/lib/requests/engine.rb'
  add_filter '/lib/requests.rb'
  add_filter '/spec'
end

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, timeout: 60)
# end
# Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :rack_test      # This is a faster driver
Capybara.javascript_driver = :poltergeist # This is slower
Capybara.default_max_wait_time = ENV['TRAVIS'] ? 60 : 15
# Adding the below to deal with random Capybara-related timeouts in CI.
# Found in this thread: https://github.com/teampoltergeist/poltergeist/issues/375
poltergeist_options = {
  js_errors: false,
  timeout: 60,
  logger: nil,
  phantomjs_logger: StringIO.new,
  phantomjs_options: [
    '--load-images=no',
    '--ignore-ssl-errors=yes'
  ]
}
Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new(app, poltergeist_options)
end

EngineCart.load_application!

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryGirl.find_definitions

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before :each do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.include Requests::Engine.routes.url_helpers
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  # config.include Devise::Test::ControllerHelpers, type: :feature
  # config.include Devise::Test::IntegrationHelpers, type: :feature
  # config.include Devise::Test::ControllerHelpers, type: :view
  config.include Warden::Test::Helpers # , type: :feature
  # config.include Warden::Test::Helpers, type: :request
  config.include Features::SessionHelpers, type: :feature
  config.before(:each, type: :feature) do
    Warden.test_mode!
    OmniAuth.config.test_mode = true
  end
  config.after(:each, type: :feature) do
    Warden.test_reset!
  end
  # config.before(:each) do
  #
  #     stub_request(:post, "http://libweb5.princeton.edu/RecapRequestService").
  #       with(body: "abc",
  #           :headers => {'Accept'=>'*/*',
  #               'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  #               'Content-Length'=>'3',
  #               'User-Agent'=>'Ruby'}).
  #       to_return(:status => 200, :body => "stubbed response", :headers => {})
  #
  #   end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end

def wait_for_ajax
  counter = 0
  while page.execute_script('return $.active').to_i > 0
    counter += 1
    sleep(0.1)
    raise 'AJAX request took longer than 20 seconds.' if counter >= 20
  end
end

def in_travis?
  !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'
end

def fixture(file)
  File.open(File.join(File.dirname(__FILE__), 'fixtures', file), 'rb')
end
