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
    end
  end
end
