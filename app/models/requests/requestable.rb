module Requests
  class Requestable

    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_reader :provider
    attr_accessor :services
    attr_accessor :preferred_id

    include Requests::Pageable
    include Requests::Aeon
    include Requests::Illiad
    include Requests::Mapable

    def initialize(bib:, holding: nil, item: nil, location: nil)
      @bib ||= bib # hash of bibliographic data
      @holding ||= holding # hash of holding data
      @item ||= item # hash of item data
      @location ||= location # hash of location matrix data
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

    def stackmap_url
      map_link(bib, holding)
    end

    def bib
      @bib
    end

    def preferred_request_id
      if item?
        item['id']
      else
        holding.first[0]
      end
    end

    def holding
      @holding
    end

    def item
      @item
    end

    def location
      @location
    end

    def location_code
      @holding[:location_code]
    end

    # non voyager options
    def thesis?
      return true if @holding["thesis"][:location_code] == 'mudd'
    end

    # graphic arts non voyager collection
    def visuals?
      return true if @holding["visuals"][:location_code] == 'ga'
    end

    # Reading Room Request
    def aeon?
      return true if @location[:aeon_location] == true  
    end

    # at an open location users may go to
    def open?
      return true if @location[:open] == true
    end

    # A closed location where items need to be retrieved from by default
    def requestable?
      return true if @location[:requestable] == true
    end

    def recap?
      return true if @location[:library][:code] == 'recap'
    end

    def recap_edd?
      return true if @location[:recap_electronic_delivery_location] == true
    end

    def missing?
      return true if @item[:status] == 'Missing'
    end

    # merge these two 
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
        if @item[:status] == 'In Process' || @item[:status] == 'On-Site - In Process'
          return true
        end
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

    def set_services service_list
      @services = service_list
    end

    def traceable?
      return true if @services.include?('trace')
    end

    def ill_eligible?
      return true if @services.include?('ill')
    end

    def voyager_managed?
      return true if @bib[:id].to_i > 0
    end

    def params
      if aeon? && !voyager_managed?
        aeon_mapped_params(bib, holding)
      end
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

    def enumerated?
      if item?
        unless item[:enum].nil?
          true
        else 
          false
        end
      else
        false
      end
    end

    def pageable?
      if charged?
        nil
      elsif !holding.first[1].key?('call_number_browse')
        nil
      elsif paging_locations.include? location['code']
        call_num = holding.first[1]['call_number_browse']
        if lc_number?(call_num)
          in_call_num_range(call_num, paging_ranges[location['code']])
        end
      end
    end

    def pageable_loc?
      if !holding.first[1].key?('call_number_browse')
        nil
      elsif paging_locations.include? location['code']
        call_num = holding.first[1]['call_number_browse']
        if lc_number?(call_num)
          in_call_num_range(call_num, paging_ranges[location['code']])
        end
      end
    end

    def pickup_locations
      if @location[:delivery_locations].size > 0
        @location[:delivery_locations] 
      end
    end


    private 

    # From Tampakis
    def unavailable_statuses
      ['Charged', 'Renewed', 'Overdue', 'On Hold', 'In transit',
       'In transit on hold', 'At bindery', 'Remote storage request',
       'Hold request', 'Recall request', 'Missing', 'Lost--Library Applied',
       'Lost--system applied', 'Claims returned', 'Withdrawn', 'On-Site - Missing', 
       'Missing','On-Site - On Hold']
    end
  end
end
