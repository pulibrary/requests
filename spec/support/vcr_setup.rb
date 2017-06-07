require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.ignore_hosts 'catalog.princeton.edu', 'libweb5.princeton.edu', Requests.config[:scsb_base], BorrowDirect::Defaults::PRODUCTION_API_BASE
  c.ignore_request do |request|
    request.uri.include? 'patron'
  end
  c.ignore_request do |request|
    request.uri.include? 'SCSB-' # don't load SCSB calls to pulsearch
  end
end
