require_dependency "requests/application_controller"
include Requests::ApplicationHelper

module Requests
  class RequestController < ApplicationController
    def index
      flash.now[:notice] = "This form is in development"
      flash.now[:notice] = "Please Supply a valid Library ID to Request"
    end

    def generate
      @id = sanitize(params[:system_id])
      @request = Requests::Request.new(@id)
      flash.now[:notice] = "You are eligible to request this item. This form is in development and DOES not submit requests yet."
      logger.info "Holdings #{@request.holdings}"
      logger.info "Items #{@request.items(@id)}"
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @request = params(params[:request])
    end

    private

      def set_request
        @request = fetch_record(params[:system_id])
      end

      # trusted params
      def request_params
        params.require(:request).permit(:id, :system_id, :request).permit!
      end
  end
end
