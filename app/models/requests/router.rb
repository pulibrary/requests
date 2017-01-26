module Requests
  class Router

    attr_accessor :requestable
    attr_reader :user
    # State Based Decisions
    def initialize(requestable:, user:)
      @requestable = requestable
      @user = user
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
    # :bd
    # :ill
    # :paging
    # :recall
    # :trace

    # user levels
    # guest - Access patron - shouldn't show recap_edd
    # barcode - no ill, no bd
    # cas - all services


    def routed_request
      requestable.set_services(calculate_services)
      requestable
    end

    # top level call, returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      services = []
      # here lies the switch case for all request types from the mega chart
      if(requestable.voyager_managed?)
        if(requestable.online?)
          services << 'online'
        else
          ## my item status is negative
          if(requestable.charged?)
            if requestable.item['enum'].nil?
              services << 'bd' # pop this off at a later point
            end
            services << 'ill'
            unless requestable.missing?
              services << 'recall'
            end
            #### other choices
            # Borrow Direct/ILL
          else #my item status is positive or non-existent churn through statuses
            ## any check at this level means items must fall in one bucket or another
            if(requestable.aeon?)
              services << 'aeon'
            elsif(requestable.annexa?)
              services << 'annexa'
            elsif(requestable.annexb?)
              services << 'annexb'
            elsif(requestable.in_process?)
              services << 'in_process'
            elsif(requestable.on_order?)
              services << 'on_order'
            elsif(requestable.recap?)
              services << 'recap'
              if(requestable.recap_edd?)
                services << 'recap_edd'
              end
            elsif(requestable.pageable?)
              services << 'paging'
            else
              services << 'on_shelf' # goes to stack mapping
              if(requestable.open?)
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

    private

    ## Behave differently if provider is cas, voyager, or access
    ## cas - access to all services
    ## barcode - no access to ill/borrow direct
    ## access - only access to recap|aeon
    def current_user_provider
      if @user.provider.nil?
        'access'
      else
        # assume it is an access/anonymous patron
        @user.provider
      end
    end
  end
end
