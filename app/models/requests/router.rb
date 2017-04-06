module Requests
  class Router
    attr_accessor :requestable
    attr_reader :user

    def initialize(requestable:, user:, has_loanable: false)
      @requestable = requestable
      @user = user
      @has_loanable = has_loanable
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
      if(requestable.voyager_managed? || requestable.scsb?)
        if(requestable.online?)
          services << 'online'
        else
          ## my item status is negative
          if requestable.charged?
            if (!requestable.enumerated? && cas_user? && !has_loanable?)
              services << 'bd'
            end
            # for mongraphs - title level check
            if (cas_user? && !has_loanable?)
              services << 'ill'
            end
            # for serials - copy level check
            if (cas_user? && requestable.enumerated?)
              services << 'ill'
            end
            # for mongraphs - title level check
            if !has_loanable? && auth_user?
              unless requestable.missing?
                services << 'recall'
              end
            end
            # for serials - copy level check
            if (auth_user? && requestable.enumerated?)
              unless requestable.missing?
                services << 'recall'
              end
            end
          elsif requestable.in_process?
            if auth_user?
              services << 'in_process'
            end
          elsif requestable.on_order?
            if auth_user?
              services << 'on_order'
            end
            #### other choices
            # Borrow Direct/ILL
          else # my item status is positive or non-existent churn through statuses
            ## any check at this level means items must fall in one bucket or another
            if requestable.aeon?
              services << 'aeon'
            elsif requestable.preservation?
              services << 'pres'
            elsif requestable.annexa?
              services << 'annexa'
            elsif requestable.annexb?
              services << 'annexb'
            # elsif(requestable.in_process? && auth_user?)
            #   services << 'in_process'
            # elsif(requestable.on_order? && auth_user?)
            #   services << 'on_order'
            elsif requestable.recap?
              services << 'recap'
              if (requestable.recap_edd? && auth_user?)
                services << 'recap_edd'
              end
            elsif requestable.pageable?
              services << 'paging'
            else
              services << 'on_shelf' # goes to stack mapping
              # suppressing Trace service for the moment, but leaving this code
              # see https://github.com/pulibrary/requests/issues/164 for info
              # if (requestable.open? && auth_user?)
              #   services << 'trace' # all open stacks items are traceable
              # end
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

      def has_loanable?
        @has_loanable
      end

      def access_user?
        if @user.guest == true
          true
        else
          false
        end
      end

      def barcode_user?
        if @user.provider == 'barcode'
          true
        else
          false
        end
      end

      def cas_user?
        if @user.provider == 'cas'
          true
        else
          false
        end
      end

      def auth_user?
        if cas_user? || barcode_user?
          true
        else
          false
        end
      end
  end
end
