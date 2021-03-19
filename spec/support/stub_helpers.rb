def stub_delivery_locations
  stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'delivery_locations.json')),
               headers: {})
end

def stub_voyager_hold_success(id, item_id, patron_id)
  stub_url = stub_voyager_status(id, item_id, patron_id)
  stub_request(:put, stub_url)
    .to_return(status: 200,
               body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-hold><note type=\"\">Your request was successful.</note></create-hold></response>",
               headers: {})
  stub_url
end

def stub_voyager_hold_failure(id, item_id, patron_id)
  stub_url = stub_voyager_status(id, item_id, patron_id)
  stub_request(:put, stub_url)
    .to_return(status: 405,
               body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>Failed to create request</reply-text><reply-code>25</reply-code><create-hold><note type=\"error\">Failure to create a hold</note></create-hold></response>",
               headers: {})
  stub_url
end

def stub_voyager_status(id, item_id, patron_id)
  stub_url = Requests.config[:voyager_api_base] + "/vxws/record/#{id}/items/#{item_id}/hold?patron=#{patron_id}&patron_homedb=" + URI.escape('1@DB')
  stub_request(:get, stub_url)
    .to_return(status: 201,
               body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><hold allowed=\"Y\"></hold></response>",
               headers: {})
  stub_url
end

def stub_clancy_post(barcode:, status: 'Item Requested', deny: 'N')
  clancy_url = "#{ENV['CLANCY_BASE_URL']}/circrequests/v1"
  stub_request(:post, clancy_url).to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"request_count\":\"1\",\"results\":[{\"item\":\"#{barcode}\",\"deny\":\"#{deny}\",\"istatus\":\"#{status}\"}]}", headers: {})
  clancy_url
end

def stub_clancy_status(barcode:, status: "Item not Found")
  stub_request(:get, "#{ENV['CLANCY_BASE_URL']}/itemstatus/v1/#{barcode}")
    .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"#{barcode}\",\"status\":\"#{status}\"}", headers: {})
end

def stub_scsb_availability(bib_id:, institution_id:, barcode:)
  scsb_availability_params = { bibliographicId: bib_id, institutionId: institution_id }
  scsb_response = [{ itemBarcode: barcode, itemAvailabilityStatus: "Available", errorMessage: nil }]
  stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
    .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
    .to_return(status: 200, body: scsb_response.to_json)
end
