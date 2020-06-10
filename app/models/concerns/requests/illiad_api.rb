module Requests
    module IlliadApi
      extend ActiveSupport::Concern
  
      def conn
        conn = Faraday.new(url: Requests.config[:illiad_api_base]) do |faraday|
          faraday.request  :multipart # allow XML data to be sent with request
          faraday.response :logger unless Rails.env.test?
          # faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
        end
        conn
      end

      def valid_ill_user?(netid)
        user = get_user(netid)
        user
      end

      def create_transaction(params)
        response = conn.post do |req|
          req.url "#{Requests.config[:illiad_api_base]}/Transaction"
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
          req.body = params.to_json
        end
        response
      end

      def create_user(params)
        response = conn.post do |req|
            req.url "#{Requests.config[:illiad_api_base]}/Users"
            req.headers['Content-Type'] = 'application/json'
            req.headers['Accept'] = 'application/json'
            req.headers['ApiKey'] = illiad_api_key
            req.body = params.to_json
          end
          response
      end

      def get_transaction(transaction_number)
        response = conn.get do |req|
          req.url "#{Requests.config[:illiad_api_base]}/Transaction/#{transaction_number}"
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
        end
        parse_illiad_response(response)
      end

      def get_user(netid)
        response = conn.get do |req|
            req.url "#{Requests.config[:illiad_api_base]}/Users/#{netid}"
            req.headers['Accept'] = 'application/json'
            req.headers['ApiKey'] = illiad_api_key
          end
          parse_illiad_response(response)
      end

      private

      def parse_illiad_response(response)
        parsed = response.status == 200 ? JSON.parse(response.body) : {}
        parsed.class == Hash ? parsed.with_indifferent_access : parsed
      rescue StandardError => error
        Rails.logger.error("Invalid response from the ILLiad server: #{error}")
        { success: false, screenMessage: 'A server error arose, please contact your local administrator for assistance.' }
      end

      def illiad_api_key
        if !Rails.env.test?
          ENV['ILLIAD_API_KEY']
        else
          'TESTME'
        end
      end

      def build_user_params(params)
        # construct valid user create json
      end

      def build_transaction_params(param)
        # construct valid transaction create params
      end
    end
end