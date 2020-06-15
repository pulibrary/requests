# frozen_string_literal: true

# require 'faraday'
# require 'faraday-cookie_jar'

module Requests
  class IlliadPatron < IlliadClient
    attr_reader :netid, :patron_id, :patron

    def initialize(patron)
      super()
      @patron = patron
      @patron_id = patron['patron_id']
      @netid = patron['netid']
    end

    def illiad_patron
      get_json_response("/ILLiadWebPlatform/Users/#{netid}")
    end

    def create_illiad_patron
      patron = post_json_response(url: 'ILLiadWebPlatform/Users', body: illiad_patron_attributes.to_json)
      if patron.blank? && error.present? && error["ModelState"].present?
        patron = illiad_patron if error["ModelState"]["UserName"] == ["Username #{netid} already exists."]
      end
      patron
    end

    private

      def illiad_patron_attributes
        ldap_patron = Requests::Ldap.find_by_netid(netid)
        addresses = ldap_patron[:address]&.split('$')
        {
          "Username" => patron['netid'], "ExternalUserId" => patron['netid'],
          "FirstName" => patron['user_first_name'] || ldap_patron[:givenname],
          "LastName" => patron['user_last_name'] || ldap_patron[:surname],
          "EmailAddress" => patron['active_email'] || ldap_patron[:email], "DeliveryMethod" => "Hold for Pickup",
          "LoanDeliveryMethod" => "Hold for Pickup", "NotificationMethod" => "Electronic",
          "Phone" => ldap_patron[:telephone], "Status" => patron['patron_group'], "Number" => ldap_patron[:universityid],
          "AuthType" => "Default", "NVTGC" => "ILL", "Department" => ldap_patron[:department], "Web" => true,
          "Address" => addresses&.shift, "Address2" => addresses&.join(', '), "City" => "Princeton", "State" => "NJ",
          "Zip" => "08544", "SSN" => patron['user_barcode'], "Cleared" => "Yes", "Site" => "Firestone"
        }
      end
  end
end
