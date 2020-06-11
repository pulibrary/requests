require 'spec_helper'

describe Requests::PickupLookup do
  context 'Pick-up Lookup' do
    let(:user_info) do
      {
        "user_name" => "Foo Request",
        "user_last_name" => "Request",
        "user_barcode" => "22101007797777",
        "email" => "foo@princeton.edu",
        "source" => "pulsearch",
        "patron_id" => "12345",
        "patron_group" => "staff"
      }.with_indifferent_access
    end

    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "502503",
          "call_number" => "AS142.V54 A458 Bd.490, etc.",
          "location_code" => "rcppa",
          "item_id" => "552328",
          "barcode" => "32101089306938",
          "enum" => "Bd.1, T.1",
          "copy_number" => "1",
          "status" => "Charged",
          "item_type" => "Gen",
          "pickup_location_code" => "fcirc"
        }.with_indifferent_access
      ]
    end

    let(:bib) do
      {
        "id" => "462029",
        "title" => "Sämtliche Werke und Briefe /",
        "author" => "Feuchtersleben, Ernst Seidler, Herbert Heger, Hedwig Blume, Hermann",
        "date" => "1987"
      }.with_indifferent_access
    end

    let(:params) do
      {
        "request" => user_info,
        "requestable" => requestable,
        "bib" => bib
      }
    end

    let(:pickup_lookup) { described_class.new(params) }

    let(:responses) do
      {
        error: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="N"><note type="error">You have already placed a request for this item.</note></recall></response>',
        success: '<?xml version="1.0" encoding="UTF-8"?><response><reply-text>ok</reply-text><reply-code>0</reply-code><recall allowed="Y"><pickup-locations usage="Mandatory"><pickup-location code="299" default="Y">.Firestone Library Circulation Desk</pickup-location><pickup-location code="533" default="N">693 TSD Circulation Desk</pickup-location><pickup-location code="356" default="N">Architecture Library Circulation Desk</pickup-location><pickup-location code="333" default="N">Donald E. Stokes Library, Wallace Hall, Circulation Desk</pickup-location><pickup-location code="303" default="N">East Asian Library Circulation Desk</pickup-location><pickup-location code="345" default="N">Engineering Library Circulation Desk</pickup-location><pickup-location code="440" default="N">Firestone Microforms Services</pickup-location><pickup-location code="293" default="N">Annex A Circulation Desk</pickup-location><pickup-location code="395" default="N">Interlibrary Services Circulation Desk</pickup-location><pickup-location code="489" default="N">Lewis Library Circulation Desk</pickup-location><pickup-location code="321" default="N">Marquand Library Circulation Desk</pickup-location><pickup-location code="309" default="N">Mendel Music Library Circulation Desk</pickup-location><pickup-location code="312" default="N">Harold P. Furth Plasma Physics Library Circulation Desk</pickup-location><pickup-location code="400" default="N">Pre-Bindery Circulation Desk</pickup-location><pickup-location code="394" default="N">Preservation Office Circulation</pickup-location><pickup-location code="427" default="N">RECAP Circulation</pickup-location><pickup-location code="315" default="N">Rare Books and Special Collections Circulation Desk</pickup-location><pickup-location code="306" default="N">Seeley G. Mudd Library Circulation Desk</pickup-location><pickup-location code="353" default="N">Technical Services Circulation</pickup-location><pickup-location code="359" default="N">Video Collection: Video Circulation Desk</pickup-location><pickup-location code="437" default="N">Borrow Direct Service. Princeton University Library</pickup-location><pickup-location code="439" default="N">zDatabase Maintenance</pickup-location>"    </pickup-locations>"    <dbkey code="" usage="Mandatory">Local Database</dbkey>"    <instructions usage="read-only">Please select an item.</instructions><last-interest-date usage="Mandatory">2017-02-11</last-interest-date><comment max_len="100" usage="Optional"/></recall></response>'
      }
    end

    describe 'All PickupLookup Requests' do
      let(:stub_url) do
        Requests.config[:voyager_api_base] + "/vxws/record/" + params['bib']['id'] +
          "/items/" + params['requestable'][0]['item_id'] +
          "/recall?patron=" + params['request']['patron_id'] +
          "&patron_group=" + params['request']['patron_group'] +
          "&patron_homedb=" + URI.escape('1@DB')
      end

      it "captures errors when the PickupLookup request is unsuccessful or malformed." do
        stub_request(:get, stub_url)
          .with(headers: { 'Accept' => '*/*' })
          .to_return(status: 405, body: responses[:error], headers: {})

        parsed_body = JSON.parse(pickup_lookup.returned)

        expect(parsed_body['response']['recall']['note']['@type']).to eq("error")
        expect(pickup_lookup.errors.size).to eq(1)
      end

      it "captures successful PickupLookup request submissions." do
        stub_request(:get, stub_url)
          .with(headers: { 'Accept' => '*/*' })
          .to_return(status: 201, body: responses[:success], headers: {})

        parsed_body = JSON.parse(pickup_lookup.returned)
        expect(parsed_body['response']['recall']['pickup-locations']['pickup-location']).to be_an(Array)
        expect(pickup_lookup.errors.size).to eq(0)
      end
    end
  end
end
