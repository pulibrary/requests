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

      unless params[:source].blank?
        request_params[:source] = sanitize(params[:source])
      end

      unless params[:mfhd].blank?
        request_params[:mfhd] = sanitize(params[:mfhd])
      end

      if request.post?
        unless params[:request][:email].blank?
          email = format_email(sanitize(params[:request][:email]))
        end
        unless params[:request][:user_name].blank?
          user_name = sanitize(params[:request][:user_name])
        end
      end

      if params[:mode].nil?
        @mode = 'standard'
      else
        @mode = sanitize(params[:mode])
      end
      @title = "Request ID: #{request_params[:system_id]}"

      @user = current_or_guest_user
      if !@user.guest?
        @patron = current_patron(@user.uid)
      elsif email && user_name
        @patron = {:netid=>nil,
                 :first_name=>nil,
                 :last_name=>user_name,
                 :active_email=>email,
                 :barcode=>'ACCESS',
                 :barcode_status=>0,
                 :barcode_status_date=>nil,
                 :university_id=>nil,
                 :patron_group=>nil,
                 :purge_date=>nil,
                 :expire_date=>nil,
                 :patron_id=>nil}.with_indifferent_access
      end
      @request = Requests::Request.new({
        system_id: request_params[:system_id],
        mfhd: request_params[:mfhd],
        source: request_params[:source],
        user: @user
      })
      ### redirect to Aeon non-voyager items
      if @request.thesis? || @request.visuals?
        redirect_to "#{Requests.config[:aeon_base]}?#{@request.requestable.first.params.to_query}"
      end
      #flash.now[:notice] = "You are eligible to request this item. This form is in development and DOES not submit requests yet."
    end

    # will request recall pickup location options from voyager
    # will convert from xml to json
    def recall_pickups
      @pickups = Requests::PickupLookup.new(params)
      render json: @pickups.returned
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @submission = Requests::Submission.new(sanitize_submission(params))
      respond_to do |format|
        if @submission.valid?
          @services = []
          service_errors = []
          recap = (recap_services & @submission.service_types).length
          recall = @submission.service_types.include? 'recall'
          if recap
            if @submission.user['user_barcode']=='ACCESS'
              #Access users cannot use recap service directly
              @services << Requests::Generic.new(@submission)
            else
              @services << Requests::Recap.new(@submission)
            end
          end

          if recall
            @services << Requests::Recall.new(@submission)
          end

          if !recap && !recall
            @services << Requests::Generic.new(@submission)
          end

          @services.each do |service|
            service.errors.each do |error|
              service_errors << error
            end
          end

        end
        if @submission.valid? && !service_errors.any?
          format.js {
            flash.now[:success] = I18n.t('requests.submit.success')
            logger.info "#Request Submission - #{@submission.as_json}"
            logger.info "Request Sent"
            @submission.service_types.each do |type|
              Requests::RequestMailer.send("#{type}_email", @submission).deliver_now
            end
          }
        else
          format.js {
            if @submission.valid? # submission was valid, but service failed
                flash.now[:error] = I18n.t('requests.submit.service_error')
                logger.error "Request Service Error"
                Requests::RequestMailer.send("service_error_email", @services).deliver_now
            else
                flash.now[:error] = I18n.t('requests.submit.error')
                logger.error "Request Submission #{@submission.errors.messages.as_json}"
            end
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
      ## This clause should go away when this systems is in production for all request types
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
          params.permit(:id, :system_id, :source, :mfhd, :user_name, :email, :user_barcode, :loc_code, :user, :requestable, :request).permit!
      end

      def mail_services
        ["paging", "annexa", "annexb", "trace", "on_order", "in_process"]
      end

      def recap_services
        ["recap"]
      end


      def current_patron(uid)
        return false unless uid
        begin
          patron_record = Faraday.get "#{Requests.config[:bibdata_base]}/patron/#{uid}"
        rescue Faraday::Error::ConnectionFailed
          logger.info("Unable to connect to #{Requests.config[:bibdata_base]}")
          return false
        end
        if patron_record.status == 403
          logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                      "#{Requests.config[:bibdata_base]}/patron/#{uid}")
          return false
        end
        if patron_record.status == 404
          logger.info("404 Patron #{uid} cannot be found in the Patron Data Service.")
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
