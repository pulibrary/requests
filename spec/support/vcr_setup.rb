require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.ignore_hosts 'webvoyage.princeton.edu', 'uat-recap.htcinc.com', 'scsb.recaplib.org', BorrowDirect::Defaults.api_base
  c.ignore_request do |request|
    request.uri.include? 'patron'
  end
  c.ignore_request do |request|
    request.uri.include? 'SCSB-' # don't load SCSB calls to pulsearch
  end
end
