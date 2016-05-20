require 'lcsort'

module Requests
  class Requestable

    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location

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

    def thesis?
      return true if @holding[:location_code] == 'thesis'
    end

    def aeon?
      return true if @location[:aeon_location] == true  
    end

    def accessible?
      return true if @location[:open] == true
    end

    def requestable?
      return true if @location[:requestable] == true
    end

    def recap?
      return true if @location[:library][:code] == 'recap'
    end

    def item?
      @item
    end

    def pageable?
      if paging_locations.include? self.location['code']
        in_call_num_range(self.holding.first[1]['call_number'], paging_ranges[self.location['code']])
      end
    end

    # This should a property of requestable. The Router can invoke this test when it looks
    # at item status and finds something unavailable. Need to confirm with Peter Bae if the only monographs rule holds
    # true for borrow direct. Currenly if a Record is not a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      return true if @bib[:format] == 'Book' && !self.aeon?
    end

    private

    def in_call_num_range(call_num, ranges)
      call_num = Lcsort.normalize(call_num)
      ranges.each do |range| 
        if range.length == 1
          return true if call_num.starts_with?(range[0])
        else
          start_range = Lcsort.normalize(range[0])
          end_range = Lcsort.truncated_range_end(range[1])
          return true if in_range?(call_num, start_range, end_range)
        end
      end
      nil
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
      f_ranges = [ ['A'], ['Q1', 'Z9999'] ]
      nec_ranges = [ ['A1', 'BL9999'], ['BT1', 'DR999'], ['DT1', 'KA9999'], ['KG1', 'VM9999'] ]
      { 
        'f' => f_ranges,
        'fnc' => f_ranges,
        'nec' => nec_ranges,
        'necnc' => nec_ranges,
      }
    end

    # From Tampakis
    def unavailable_statuses
      ['Charged', 'Renewed', 'Overdue', 'On hold', 'In transit',
       'In transit on hold', 'At bindery', 'Remote storage request',
       'Hold request', 'Recall request', 'Missing', 'Lost--library applied',
       'Lost--system applied', 'Claims returned', 'Withdrawn']
    end
  end
end
