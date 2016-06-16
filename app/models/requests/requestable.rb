require 'lcsort'

module Requests
  class Requestable

    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_reader :provider
    attr_writer :services

    def initialize(params)
      @bib = params[:bib] # hash of bibliographic data
      @holding = params[:holding] # hash of holding data
      @item = params[:item] # hash of item data
      @location = params[:location] # hash of location matrix data
    end

    def type
      if @item
        'item'
      elsif @holding
        'holding'
      else
        'bib'
      end
    end

    def location_code
      @holding[:location_code]
    end

    # non voyager options
    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def visuals?
      return true if @holding[:location_code] == 'visuals'
    end

    def aeon?
      return true if @location[:aeon_location] == true  
    end

    def open?
      return true if @location[:open] == true
    end

    def requestable?
      return true if @location[:requestable] == true
    end

    def recap?
      return true if @location[:library][:code] == 'recap'
    end

    def recap_edd?
      return true if @location[:recap_electronic_delivery_location] == true
    end

    def annexa?
      return true if @location[:library][:code] == 'annexa'
    end

    # locations temporarily moved to annex should work
    def annexb?
      return true if @location[:library][:code] == 'annexb'
    end

    def circulates?
      return true if @location[:circulates] == true
    end

    def always_requestable?
      return true if @location[:always_requestable] == true
    end

    def in_process?
      if item?
        return true if @item[:status] == 'In Process'
      end
    end

    def on_order?
      if item?
        return true if @item[:status].starts_with?('On-Order')
      end
    end

    def item?
      @item
    end

    def services
      @services
    end

    def voyager_managed?
      return true if @bib[:id].to_i > 0
    end

    def online?
      return true if @location[:library][:code] == 'online'
    end

    def charged?
      if(item?)
        if(unavailable_statuses.include?(@item[:status]))
          return true
        else
          nil
        end
      end
    end

    def pageable?
      if charged?
        nil
      elsif paging_locations.include? self.location['code']
        in_call_num_range(self.holding.first[1]['call_number'], paging_ranges[self.location['code']])
      end
    end

    # This should a property of requestable. The Router can invoke this test when it looks
    # at item status and finds something unavailable. Need to confirm with Peter Bae if the only monographs rule holds
    # true for borrow direct. Currenly if a Record is not a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      return true if @bib[:format] == 'Book' && !aeon?
    end

    def pickup_locations
      if @location[:delivery_locations].size > 0
        @location[:delivery_locations] 
      end
    end

    private
    def in_call_num_range(call_num, ranges)
      call_num = Lcsort.normalize(call_num)
      pageable = nil
      ranges.each do |range| 
        start_range = Lcsort.normalize(range[0])
        end_range = Lcsort.truncated_range_end(range[1])
        if in_range?(call_num, start_range, end_range)
          pageable = true
        end
      end
      pageable
    end

    def in_range?(call_num, start_range, end_range)
      if(call_num >= start_range && call_num <= end_range)
        return true
      end
    end

    def paging_locations
      ['f', 'fnc', 'xl', 'xlnc', 'nec', 'necnc']
    end

    def paging_ranges
      f_ranges = [ ['A1', 'AZ9999'], ['Q1', 'Z9999'] ]
      nec_ranges = [ ['A1', 'BL9999'], ['BT1', 'DR9999'], ['DT1', 'KA9999'], ['KG1', 'VM9999'] ]
      xl_ranges = [ ['A1', 'Z9999'] ]
      { 
        'f' => f_ranges,
        'fnc' => f_ranges,
        'nec' => nec_ranges,
        'necnc' => nec_ranges,
        'xl' => xl_ranges,
        'xlnc' => xl_ranges,
      }
    end 

    # From Tampakis
    def unavailable_statuses
      ['Charged', 'Renewed', 'Overdue', 'On hold', 'In transit',
       'In transit on hold', 'At bindery', 'Remote storage request',
       'Hold request', 'Recall request', 'Missing', 'Lost--Library Applied',
       'Lost--system applied', 'Claims returned', 'Withdrawn']
    end
  end
end
