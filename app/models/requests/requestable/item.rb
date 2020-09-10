class Requests::Requestable
  class Item < SimpleDelegator
    def pickup_location_id
      __getobj__['pickup_location_id'] || ""
    end

    # pickup_location_code on the item level
    def pickup_location_code
      __getobj__['pickup_location_code'] || ""
    end

    def item_type
      __getobj__['item_type'] || ""
    end

    class NullItem
      def present?
        false
      end

      def blank?
        true
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
    end
  end
end
