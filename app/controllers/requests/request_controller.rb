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
      @user = current_or_guest_user
      request_params[:user] = @user.uid
      @request = Requests::Request.new(request_params)
      flash.now[:notice] = "You are eligible to request this item. This form is in development and DOES not submit requests yet."
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      # @request = Request::Submission.new(params[:request])
      # @request.requested_items.each do |item|
      #   item.send
      # end
      binding.pry
    end

    # shim for pageable locations 
    def pageable
      request_params[:system_id] = sanitize(params[:system_id])
      @user = current_or_guest_user
      request_params[:user] = @user.uid
      @request = Requests::Request.new(request_params)
      if @request.has_pageable?
        respond_to do | format |
          format.json { render json: { pageable: true } }
          format.html { redirect_to "/requests/#{@request.system_id}" }
        end
      else
        format.json { render json: { pageable: false } }
        format.html { redirect_to "https://library.princeton.edu/requests/#{@request.system_id}" }
      end
    end

    private
      # trusted params
      def request_params
        params.permit(:id, :system_id, :mfhd, :f_name, :l_name, :email, :user_barcode, :loc_code, :user).permit!
      end


  end
end
