module Requests
  class Item
    attr_reader :id
    attr_reader :copy_number
    attr_reader :item_sequence_number
    attr_reader :temp_location
    attr_reader :status
    attr_reader :status_date
    attr_reader :barcode
    attr_accessor :enumeration
    attr_accessor :start_page
    attr_accessor :end_page
  end
end
