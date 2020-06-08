def stub_delivery_locations
  stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'delivery_locations.json')),
               headers: {})
end

def stub_voyager_hold_success(id, item_id, patron_id)
  stub_url = Requests.config[:voyager_api_base] + "/vxws/record/#{id}/items/#{item_id}/hold?patron=#{patron_id}&patron_homedb=" + URI.escape('1@DB')
  stub_request(:put, stub_url)
    .to_return(status: 200,
               body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><create-hold><note type=\"\">Your request was successful.</note></create-hold></response>",
               headers: {})
  stub_request(:get, stub_url)
    .to_return(status: 201,
               body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><hold allowed=\"Y\"></hold></response>",
               headers: {})
end
