require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.ignore_hosts 'catalog.princeton.edu', 'libweb5.princeton.edu'
  c.ignore_request do |request|
    request.uri.include? 'patron'
  end
end
