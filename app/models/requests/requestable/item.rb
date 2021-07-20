class Requests::Requestable
  class Item < SimpleDelegator
    def pick_up_location_id
      self['pickup_location_id'] || ""
    end

    # pick_up_location_code on the item level
    def pick_up_location_code
      self['pickup_location_code'] || ""
    end

    def item_type
      self['item_type'] || ""
    end

    def enum_value
      self['enum_display'] || ""
    end

    def cron_value
      self['chron_display'] || ""
    end

    def item_data?
      self[:id].present?
    end

    def temp_loc?
      self[:temp_loc].present?
    end

    def on_reserve?
      self[:on_reserve] == 'Y'
    end

    def inaccessible?
      status == 'Inaccessible'
    end

    def hold_request?
      status_label == 'Hold Shelf'
    end

    def enumerated?
      self[:enum_display].present?
    end

    # item type on the item level
    def item_type_non_circulate?
      ['NoCirc', 'Closed', 'Res-No'].include? item_type
    end

    def id
      self['id']
    end

    def use_statement
      self[:use_statement]
    end

    def collection_code
      self[:collection_code]
    end

    def missing?
      status_label == 'Missing'
    end

    def charged?
      unavailable_statuses.include?(status_label)
    end

    def status
      return self[:status] if self[:status].present?
      if available?
        "Available"
      else
        "Not Available"
      end
    end

    def status_label
      self[:status_label]
    end

    def available?
      available_statuses.include?(status_label)
    end

    def barcode?
      /^[0-9]+/.match(barcode).present?
    end

    def barcode
      self[:barcode]
    end

    def scsb?
      ['scsbnypl', 'scsbcul'].include? self["location_code"]
    end

    class NullItem
      def nil?
        true
      end

      def present?
        false
      end

      def blank?
        true
      end

      def item_data?
        false
      end

      def pick_up_location_id
        ""
      end

      def pick_up_location_code
        ""
      end

      def item_type
        ""
      end

      def enum_value
        ""
      end

      def cron_value
        ""
      end

      def temp_loc?
        false
      end

      def on_reserve?
        false
      end

      def inaccessible?
        false
      end

      def hold_request?
        false
      end

      def enumerated?
        false
      end

      def item_type_non_circulate?
        false
      end

      def id
        nil
      end

      def use_statement
        ''
      end

      def collection_code
        ''
      end

      def missing?
        false
      end

      def charged?
        false
      end

      def status_label
        'Not Available'
      end

      def status
        ''
      end

      def available?
        false
      end

      def barcode?
        false
      end

      def barcode
        ''
      end

      def scsb?
        false
      end
    end

    private

      def available_statuses
        voyager = ["Not Charged", "On-Site", "On Shelf"]
        scsb = ["Available"]
        alma = ['Item in place']
        voyager + scsb + alma
      end

      def unavailable_statuses
        voyager = ['unavailable', 'Charged', 'Renewed', 'Overdue', 'On Hold', 'Hold Request', 'In transit',
                   'In transit on hold', 'In Transit Discharged', 'In Transit On Hold', 'At bindery', 'Remote storage request',
                   'Hold request', 'Recall request', 'Missing', 'Lost--Library Applied',
                   'Lost--System Applied', 'Claims returned', 'Withdrawn', 'On-Site - Missing',
                   'Missing', 'On-Site - On Hold', 'Inaccessible']
        scsb = ['Not Available', "Item Barcode doesn't exist in SCSB database."]
        alma = ['Claimed Returned', 'Lost', 'Hold Shelf', 'Transit', 'Missing', 'Resource Sharing Request',
                'Lost Resource Sharing Item', 'Requested', 'In Transit to Remote Storage', 'Lost and paid',
                'Loan', 'Controlled Digital Lending', 'At Preservation', 'Technical - Migration', 'Preservation and Conservation']
        voyager + scsb + alma
      end
  end
end
