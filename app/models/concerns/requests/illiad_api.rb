module Requests
    module IlliadApi
      extend ActiveSupport::Concern
  
      def illiad_conn
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
        response = illiad_conn.post do |req|
          req.url '/ILLiadWebPlatform/Transaction'
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
          req.body = params.to_json
        end
        response
      end

      def create_user(params)
        response = illiad_conn.post do |req|
            req.url '/ILLiadWebPlatform/Users'
            req.headers['Content-Type'] = 'application/json'
            req.headers['Accept'] = 'application/json'
            req.headers['ApiKey'] = illiad_api_key
            req.body = params.to_json
          end
          response
      end

      def get_transaction(transaction_number)
        response = illiad_conn.get do |req|
          req.url "/ILLiadWebPlatform/Transaction/#{transaction_number}"
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
        end
        parse_illiad_response(response)
      end

      def get_user(netid)
        response = illiad_conn.get do |req|
            req.url "/ILLiadWebPlatform/Users/#{netid}"
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


    end
end