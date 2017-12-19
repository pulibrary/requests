def stub_delivery_locations
  WebMock.stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")
         .to_return(status: 200,
                    body: File.read(File.join(fixture_path, 'bibdata', 'delivery_locations.json')),
                    headers: {})
end
