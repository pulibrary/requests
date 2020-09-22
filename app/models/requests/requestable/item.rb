class Requests::Requestable
  class Item < SimpleDelegator
    def pickup_location_id
      self['pickup_location_id'] || ""
    end

    # pickup_location_code on the item level
    def pickup_location_code
      self['pickup_location_code'] || ""
    end

    def item_type
      self['item_type'] || ""
    end

    def enum_value
      self['enum']
    end

    def cron_value
      self['chron']
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
      status == 'Hold Request'
    end

    def enumerated?
      self[:enum].present?
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
      status == 'Missing'
    end

    def charged?
      unavailable_statuses.include?(status) || unavailable_statuses.include?(scsb_status)
    end

    def status
      self[:status]
    end

    def scsb_status
      self[:scsb_status]
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

      def pickup_location_id
        ""
      end

      def pickup_location_code
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
    end

    private

      def unavailable_statuses
        ['Charged', 'Renewed', 'Overdue', 'On Hold', 'Hold Request', 'In transit',
         'In transit on hold', 'In Transit Discharged', 'In Transit On Hold', 'At bindery', 'Remote storage request',
         'Hold request', 'Recall request', 'Missing', 'Lost--Library Applied',
         'Lost--System Applied', 'Claims returned', 'Withdrawn', 'On-Site - Missing',
         'Missing', 'On-Site - On Hold', 'Inaccessible', 'Not Available', "Item Barcode doesn't exist in SCSB database."]
      end
  end
end
