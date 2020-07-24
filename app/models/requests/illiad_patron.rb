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
      return nil if patron.blank?
      patron = post_json_response(url: 'ILLiadWebPlatform/Users', body: illiad_patron_attributes.to_json)
      if patron.blank? && error.present? && error["ModelState"].present?
        patron = illiad_patron if error["ModelState"]["UserName"] == ["Username #{netid} already exists."]
      end
      patron
    end

    private

      def illiad_patron_attributes
        ldap_patron = Requests::Ldap.find_by_netid(netid)
        return nil if ldap_patron.blank?
        illiad_status = illiad_status(ldap_status: ldap_patron[:status], ldap_pustatus: ldap_patron[:pustatus], ldap_department: ldap_patron[:department], ldap_title: ldap_patron[:title])
        return nil if illiad_status.blank?
        addresses = ldap_patron[:address]&.split('$')
        {
          "Username" => patron['netid'], "ExternalUserId" => patron['netid'], "FirstName" => patron['first_name'] || ldap_patron[:givenname],
          "LastName" => patron['last_name'] || ldap_patron[:surname], "LoanDeliveryMethod" => "Hold for Pickup", "NotificationMethod" => "Electronic",
          "EmailAddress" => patron['active_email'] || ldap_patron[:email], "DeliveryMethod" => "Hold for Pickup",
          "Phone" => ldap_patron[:telephone], "Status" => illiad_status, "Number" => ldap_patron[:universityid],
          "AuthType" => "Default", "NVTGC" => "ILL", "Department" => ldap_patron[:department], "Web" => true,
          "Address" => addresses&.shift, "Address2" => addresses&.join(', '), "City" => "Princeton", "State" => "NJ",
          "Zip" => "08544", "SSN" => patron["barcode"], "Cleared" => "Yes", "Site" => "Firestone"
        }
      end

      def illiad_status(ldap_status:, ldap_pustatus:, ldap_department:, ldap_title:)
        return nil if ldap_pustatus.blank? || ldap_pustatus[0] == 'x'

        if ldap_status == "staff"
          illiad_staff_status(ldap_department: ldap_department, ldap_title: ldap_title)
        elsif ldap_status == "student"
          student_mappings = { "gradetdc" => "GS - Graduate Student", "undergraduate" => "U - Undergraduate", "graduate" => "GS - Graduate Student" }
          student_mappings[ldap_pustatus]
        elsif ldap_status == "faculty"
          if ldap_title.present? && ldap_title.include?("Visiting")
            "F - Visiting Faculty"
          else
            "F - Faculty"
          end
        end
      end

      def illiad_staff_status(ldap_department:, ldap_title:)
        if ldap_department.present? && ldap_department.include?("Library")
          "GS - Library Staff"
        elsif ldap_title.present?
          illiad_staff_title_status(ldap_title: ldap_title)
        else
          "GS - University Staff"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def illiad_staff_title_status(ldap_title:)
        if ldap_title.include?("Visiting Research")
          "GS - Visiting Research Scholar"
        elsif ldap_title.include?("Senior Research Scholar")
          "F - Senior Research Scholar"
        elsif ldap_title.include?("Research Scholar")
          "F - Research Scholar"
        elsif ldap_title.include?("Senior Professional")
          "F - Senior Professional Specialist"
        elsif ldap_title.match?(/Post*doc*Reseach*/i)
          "GS - Post doc Research Associate"
        elsif ldap_title.match?(/Post*doc*Fellow*/i)
          "F - Postdoctoral Fellow -- Teaching"
        elsif ldap_title.match?(/Vist*Fellow*/i)
          "GS - Visiting Fellow"
        else
          "GS - University Staff"
        end
      end
    # rubocop:enable Metrics/MethodLength
  end
end
