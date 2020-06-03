module Requests
  class Router
    attr_accessor :requestable
    attr_reader :user, :any_loanable

    def initialize(requestable:, user:, any_loanable: false)
      @requestable = requestable
      @user = user
      @any_loanable = any_loanable
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
      if (requestable.voyager_managed? || requestable.scsb?) && requestable.online?
        ['online']
      elsif requestable.voyager_managed? || requestable.scsb?
        calculate_voyager_or_scsb_services
      else # Default Service is Aeon
        ['aeon']
      end
    end

    private

      # rubocop:disable Metrics/MethodLength
      def calculate_voyager_or_scsb_services
        if requestable.charged? && !requestable.aeon? ## my item status is negative
          calculate_unavailable_services
        elsif (requestable.in_process? || requestable.on_order?) && !auth_user?
          []
        elsif requestable.in_process?
          ['in_process']
        elsif requestable.on_order?
          ['on_order']
        # my item status is positive or non-existent churn through statuses
        ## any check at this level means items must fall in one bucket or another
        elsif requestable.aeon?
          ['aeon']
        elsif requestable.preservation?
          ['pres']
        elsif requestable.annexa?
          ['annexa']
        elsif requestable.annexb?
          ['annexb']
        elsif requestable.plasma?
          ['ppl']
        elsif requestable.lewis?
          ['lewis']
        elsif requestable.recap?
          calculate_recap_services
        elsif requestable.pageable?
          ['paging']
        else
          calculate_on_shelf_services
          # suppressing Trace service for the moment, but leaving this code
          # see https://github.com/pulibrary/requests/issues/164 for info
          # if (requestable.open? && auth_user?)
          #   services << 'trace' # all open stacks items are traceable
          # end
        end
      end
      # rubocop:enable Metrics/MethodLength
      def calculate_on_shelf_services
        services = ['on_shelf'] 
        services << 'on_shelf_edd' if requestable.circulates?
        services
      end

      def calculate_recap_services
        return ['recap_no_items'] unless requestable.item_data?
        services = []
        return services << 'ask_me' if requestable.scsb_in_library_use?
        # Add physical recap delivery during campus closure
        services = ['recap']
        services << 'recap_edd' if requestable.recap_edd? && auth_user?
        services
      end

      def calculate_unavailable_services
        []
        # TODO: Uncomment this block when library returns to normal operation
        # services = []
        # if (!requestable.enumerated? && cas_user? && !any_loanable?)
        #   services << 'bd'
        # end
        # # for mongraphs - title level check
        # if (cas_user? && !any_loanable?)
        #   services << 'ill'
        # end
        # # for serials - copy level check
        # if (cas_user? && requestable.enumerated?)
        #   services << 'ill'
        # end
        # # for mongraphs - title level check
        # if !any_loanable? && auth_user?
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
        # services
      end

      def any_loanable?
        @any_loanable
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
