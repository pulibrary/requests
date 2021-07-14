def stub_delivery_locations
  stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'delivery_locations.json')),
               headers: {})
end

def stub_alma_hold_success(id, mfhd, item_id, patron_id)
  stub_url = "#{Alma.configuration.region}/almaws/v1/bibs/#{id}/holdings/#{mfhd}/items/#{item_id}/requests?user_id=#{patron_id}"
  stub_request(:post, stub_url)
    .to_return(status: 200,
               body: fixture("alma_hold_response.json"),
               headers: { 'content-type': 'application/json' })
  stub_url
end

def stub_alma_hold_failure(id, mfhd, item_id, patron_id)
  stub_url = "#{Alma.configuration.region}/almaws/v1/bibs/#{id}/holdings/#{mfhd}/items/#{item_id}/requests?user_id=#{patron_id}"
  stub_request(:post, stub_url)
    .to_return(status: 400,
               body: fixture("alma_hold_error_no_library_response.json"),
               headers: { 'content-type': 'application/json' })
  stub_url
end

def stub_clancy_post(barcode:, status: 'Item Requested', deny: 'N')
  clancy_url = "#{Requests.config[:clancy_base]}/circrequests/v1"
  stub_request(:post, clancy_url).to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"request_count\":\"1\",\"results\":[{\"item\":\"#{barcode}\",\"deny\":\"#{deny}\",\"istatus\":\"#{status}\"}]}", headers: {})
  clancy_url
end

def stub_clancy_status(barcode:, status: "Item not Found")
  stub_request(:get, "#{Requests.config[:clancy_base]}/itemstatus/v1/#{barcode}")
    .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"#{barcode}\",\"status\":\"#{status}\"}", headers: {})
end

def stub_scsb_availability(bib_id:, institution_id:, barcode:, item_availability_status: "Available")
  scsb_availability_params = { bibliographicId: bib_id, institutionId: institution_id }
  scsb_response = [{ itemBarcode: barcode, itemAvailabilityStatus: item_availability_status, errorMessage: nil }]
  stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
    .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
    .to_return(status: 200, body: scsb_response.to_json)
end
