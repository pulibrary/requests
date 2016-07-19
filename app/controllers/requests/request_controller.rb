require_dependency "requests/application_controller"
require 'faraday'

include Requests::ApplicationHelper

module Requests
  class RequestController < ApplicationController
    def index
      flash.now[:notice] = "This form is in development"
      flash.now[:notice] = "Please Supply a valid Library ID to Request"
    end

    def generate
      request_params[:system_id] = sanitize(params[:system_id])
      unless params[:source].nil?
        request_params[:source] = sanitize(params[:source])
      end
      @title = "Request ID: #{request_params[:system_id]}"
      unless params[:mfhd].nil?
        request_params[:mfhd] = sanitize(params[:mfhd])
      end
      @user = current_or_guest_user
      unless @user.guest?
        @patron = current_patron(@user.uid)
      end
      request_params[:user] = @user.uid
      @request = Requests::Request.new(request_params)
      #flash.now[:notice] = "You are eligible to request this item. This form is in development and DOES not submit requests yet."
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @submission = Requests::Submission.new(sanitize_submission(params))
      respond_to do |format|
        if @submission.valid?
          service = @submission.service_type
          if mail_services.include? service
            Requests::RequestMailer.send("#{service}_email", @submission).deliver_now
          end
          format.js { 
            flash.now[:success] = I18n.t('requests.submit.success') 
            logger.info "#Request Submission - #{@submission.as_json}"
          }
        else
          format.js { 
            flash.now[:error] = I18n.t('requests.submit.error')
            logger.error "Request Submission #{@submission.errors.messages.as_json}"
          }
        end
      end
    end

    # shim for pageable locations 
    def pageable
      request_params[:system_id] = sanitize(params[:system_id])
      @user = current_or_guest_user
      request_params[:user] = @user.uid
      unless params[:mfhd].nil?
        request_params[:mfhd] = sanitize(params[:mfhd])
      end
      @request = Requests::Request.new(request_params)
      if @request.has_pageable?
        respond_to do | format |
          format.json { render json: { pageable: true } }
          format.html { redirect_to "/requests/#{@request.system_id}" }
        end
      else
        respond_to do | format |
          format.json { render json: { pageable: false } }
          format.html { redirect_to "https://library.princeton.edu/requests/#{@request.system_id}" }
        end
      end
    end

    private
      # trusted params
      def request_params
        params.permit(:id, :system_id, :source, :mfhd, :user_name, :email, :user_barcode, :loc_code, :user, :requestable).permit!
      end

      def mail_services
        ["paging", "annexa", "annexb", "trace", "on_order", "in_process"]
      end


      def current_patron(netid)
        return false unless netid
        begin
          patron_record = Faraday.get "#{Requests.config[:bibdata_base]}/patron/#{netid}"
        rescue Faraday::Error::ConnectionFailed
          logger.info("Unable to connect to #{Requests.config[:bibdata_base]}")
          return false
        end

        if patron_record.status == 403
          logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                      "#{Requests.config[:bibdata_base]}/patron/#{netid}")
          return false
        end
        if patron_record.status == 404
          logger.info("404 Patron #{netid} cannot be found in the Patron Data Service.")
          return false
        end
        if patron_record.status == 500
          logger.info('Error Patron Data Service.')
          return false
        end
        patron = JSON.parse(patron_record.body).with_indifferent_access
        logger.info(patron.to_hash.to_s)
        patron
      end

      def sanitize_submission params
        params[:requestable].each do |requestable|
          if requestable.key? 'user_supplied_enum'
            params['user_supplied_enum'] = sanitize(requestable['user_supplied_enum'])
          end
        end
        params
      end

  end
end
