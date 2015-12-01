VCR.configure do |c|
  #the directory where your cassettes will be saved
  c.cassette_library_dir = 'spec/vcr'
  # your HTTP request service. You can also use fakeweb, typhoeus, and more
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true # This means that we don't *always* have to use VCR for HTTP, only when we want
  # TODO Filter Sensitive Paramters
  # c.filter_sensitive_data('<TEST BARCODE>')  { "#{ENV['TEST_BARCODE']}"}
end