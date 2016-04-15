module Requests
  class Router
    def initialize(requestable, user)
      @requestable = requestable
      @user = user
    end

    # top level call, returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      services = {}
      # here lies the switch case for all request types from the mega chart
      # 
      services
    end

    # returns a hash of all possible services for the combmination of 
    # a 'requestable' item and a the user object passed in.
    def services
      @services
    end

    def current_user_provider
      if !@user.provider.nil?
        @user.provider
      else
        # assume it is an access/anonymous patron
        'access'
      end
    end

    ### Utitlities for dealing with borrow direct's quirks

    # If Record is not a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if @requestable.item[:status] == 'check for not available' and self.doc[:format] == 'Book'
        return true
      end
    end

    # actually check to see if borrow direct is available
    def borrow_direct_available?
    end
    
    #When ISBN Match
    def borrow_direct_exact?
    end

    # When Title or Author Matches
    def borrow_direct_fuzzy?
    end
  end
end
