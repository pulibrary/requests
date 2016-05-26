require_dependency "requests/application_controller"
include Requests::ApplicationHelper

module Requests
  class RequestController < ApplicationController
    def index
      flash.now[:notice] = "This form is in development"
      flash.now[:notice] = "Please Supply a valid Library ID to Request"
    end

    def generate
      request_params[:system_id] = sanitize(params[:system_id])
      unless params[:mfhd].nil?
        request_params[:mfhd] = sanitize(params[:mfhd])
      end
      request_params[:user] = current_user
      @request = Requests::Request.new(request_params)
      flash.now[:notice] = "You are eligible to request this item. This form is in development and DOES not submit requests yet."
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @request = Request::Submission.new(params[:request])
      @request.requested_items.each do |item|
        item.send
      end
    end

    private
      # trusted params
      def request_params
        params.permit(:id, :system_id, :mfhd, :f_name, :l_name, :email, :user_barcode).permit!
      end
  end
end
