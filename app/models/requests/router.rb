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
      requestable.services = calculate_services
      requestable
    end

    # top level call, returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      services = []
      # here lies the switch case for all request types from the mega chart
      if requestable.voyager_managed? || requestable.scsb?
        if requestable.online?
          services << 'online'
        else
          ## my item status is negative
          if requestable.charged? && !requestable.aeon?
            # TODO: Uncomment this block when library returns to normal operation
            # if (!requestable.enumerated? && cas_user? && !has_loanable?)
            #   services << 'bd'
            # end
            # # for mongraphs - title level check
            # if (cas_user? && !has_loanable?)
            #   services << 'ill'
            # end
            # # for serials - copy level check
            # if (cas_user? && requestable.enumerated?)
            #   services << 'ill'
            # end
            # # for mongraphs - title level check
            # if !has_loanable? && auth_user?
            #   unless requestable.missing? || requestable.inaccessible? || requestable.hold_request? || requestable.recap?
            #     services << 'recall'
            #   end
            # end
            # # for serials - copy level check
            # if (auth_user? && requestable.enumerated?)
            #   unless requestable.missing? || requestable.inaccessible? || requestable.hold_request? || requestable.recap?
            #     services << 'recall'
            #   end
            # end
          elsif requestable.in_process?
            services << 'in_process' if auth_user?
          elsif requestable.on_order?
            services << 'on_order' if auth_user?
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
            elsif requestable.plasma?
              services << 'ppl'
            elsif requestable.lewis?
              services << 'lewis'
            elsif requestable.recap?
              if requestable.has_item_data?
                # No physical recap delivery during campus closure
                # services << 'recap'
                services << 'recap_edd' if requestable.recap_edd? && auth_user?
              # No physical recap delivery during campus closure
              else
                services << 'recap_no_items'
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
      else # Default Service is Aeon
        services << 'aeon'
      end
      services
    end

    private

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
