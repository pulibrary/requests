module Requests
  class Router

    # State Based Decisions
    def initialize(requestable, user)
      @requestable = requestable
      @user = user
      @services = self.calculate_services
    end

    # Possible Services
    # :online
    # :annexa
    # :annexb
    # :on_shelf
    # :on_order
    # :in_process
    # :annex
    # :recap
    # :recap_edd
    # :borrow_direct
    # :ill
    # :paging
    # :recall
    # :trace

    def routed_request
      @requestable.services = @services
      @requestable
    end

    # top level call, returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      services = []
      # here lies the switch case for all request types from the mega chart
      if(@requestable.voyager_managed?)
        if(@requestable.online?) # I am online
          services << 'online'
        else
          ## my item status is negative
          if(@requestable.charged?)
            services << 'bd' # pop this off at a later point
            services << 'ill'
            services << 'recall'
            #### other choices
            # Borrow Direct/ILL
          else #my item status is positive or non-existent churn through statuses
            ## any check at this level means items must fall in one bucket or another
            if(@requestable.aeon?)
              services << 'aeon'
            elsif(@requestable.annexa?)
              services << 'annexa'
            elsif(@requestable.annexb?)
              services << 'annexb'
            elsif(@requestable.in_process?)
              services << 'in_process'
            elsif(@requestable.on_order?)
              services << 'on_order'
            elsif(@requestable.recap?)
              services << 'recap'
              if(@requestable.recap_edd?)
                services << 'recap_edd'
              end
            elsif(@requestable.pageable?)
              services << 'paging'
            else
              services << 'on_shelf' # goes to stack mapping
              if(@requestable.open?)  
                services << 'trace' # all open stacks items are traceable
              end
            end
          end
        end
      else # I am not from Voyager
        services << 'aeon'
      end
      services
    end

    # returns a hash of all possible services for the combmination of 
    # a 'requestable' item and a the user object passed in.
    def services
      @services
    end

    private

    ## Behave differently if provider is cas, voyager, or access
    ## cas - access to all services
    ## voyager - no access to ill/borrow direct
    ## access - only access to recap|aeon
    def current_user_provider
      if !@user.provider.nil?
        @user.provider
      else
        # assume it is an access/anonymous patron
        'access'
      end
    end

    ## 
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
