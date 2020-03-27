require_dependency "requests/application_controller"
require 'faraday'

include Requests::ApplicationHelper

module Requests
  class RequestController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:borrow_direct]

    def index
      redirect_to('/')
    end

    def generate
      request_params[:system_id] = sanitize(params[:system_id])

      request_params[:source] = sanitize(params[:source]) if params[:source].present?

      request_params[:mfhd] = sanitize(params[:mfhd]) if params[:mfhd].present?

      if request.post?
        email = format_email(sanitize(params[:request][:email])) if params[:request][:email].present?
        user_name = sanitize(params[:request][:user_name]) if params[:request][:user_name].present?
      end

      @mode = if params[:mode].nil?
                'standard'
              else
                sanitize(params[:mode])
              end
      @title = "Request ID: #{request_params[:system_id]}"

      @user = current_or_guest_user
      if !@user.guest?
        @patron = current_patron(@user.uid)
      elsif email && user_name
        @patron = access_patron(email, user_name)
      end
      flash.now[:error] = "A problem occurred looking up your library account." if @patron == false

      # FIXME: Only create the object if needed. Right now it is getting created twice.
      # Before and after the user logs in.
      @request = Requests::Request.new(
        system_id: request_params[:system_id],
        mfhd: request_params[:mfhd],
        source: request_params[:source],
        user: @user
      )
      ### redirect to Aeon non-voyager items or single Aeon requestable
      if @request.thesis?
        redirect_to "#{Requests.config[:aeon_base]}?#{@request.requestable.first.aeon_mapped_params.to_query}"
      elsif @request.has_single_aeon_requestable?
        redirect_to @request.requestable.first.aeon_request_url(@request.ctx)
      end
    end

    # will request recall pickup location options from voyager
    # will convert from xml to json
    def recall_pickups
      @pickups = Requests::PickupLookup.new(params)
      render json: @pickups.returned
    end

    def borrow_direct
      @isbns = sanitize(params[:isbns]).split(',')
      query_params = { isbn: @isbns.first }
      bd = Requests::BorrowDirectLookup.new
      if params[:barcode].nil?
        bd.find(query_params)
      else
        bd.find(query_params, sanitize(params[:barcode]))
      end
      render json: bd.find_response.to_json
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @submission = Requests::Submission.new(sanitize_submission(params))
      respond_to do |format|
        if @submission.valid?
          @services = []
          service_errors = []
          success_messages = []
          if @submission.service_types.include? 'recap'
            @services << if @submission.user['user_barcode'] == 'ACCESS'
                           # Access users cannot use recap service directly
                           Requests::Generic.new(@submission)
                         else
                           Requests::Recap.new(@submission)
                         end
          end
          @services << Requests::Recall.new(@submission) if @submission.service_types.include? 'recall'

          if @submission.service_types.include? 'bd'
            bd_success_message = I18n.t('requests.submit.bd_success')
            bd_request = Requests::BorrowDirect.new(@submission)
            bd_request.handle
            @services << bd_request
            success_messages << "#{bd_success_message} Your request number is #{bd_request.sent[0][:request_number]}" unless bd_request.errors.count >= 1
          end

          # if !recap && !recall && !bd !(a1 & a2).empty?
          if (@submission.service_types & ['bd', 'recap', 'recall']).empty?
            @services << Requests::Generic.new(@submission)
            success_messages << I18n.t('requests.submit.success')
          end

          @submission.service_types.each do |type|
            success_messages << I18n.t("requests.submit.#{type}_success") unless ['bd', 'recap_no_items'].include? type
          end
          @services.each do |service|
            service.errors.each do |error|
              service_errors << error
            end
          end
        end
        if @submission.valid? && !service_errors.any?
          format.js do
            flash.now[:success] = success_messages.join(' ')
            logger.info "#Request Submission - #{@submission.as_json}"
            logger.info "Request Sent"
            unless @submission.service_types.include? 'bd'
              @submission.service_types.each do |type|
                Requests::RequestMailer.send("#{type}_email", @submission).deliver_now
                Requests::RequestMailer.send("#{type}_confirmation", @submission).deliver_now if ['on_order', 'in_process', 'pres', 'recap_no_items', 'lewis', 'ppl'].include? type
                Requests::RequestMailer.send("scsb_recall_email", @submission).deliver_now if type == 'recall' && @submission.scsb?
              end
            end
          end
        else
          format.js do
            if @submission.valid? # submission was valid, but service failed
              flash.now[:error] = I18n.t('requests.submit.service_error')
              logger.error "Request Service Error"
              Requests::RequestMailer.send("service_error_email", @services).deliver_now
            else
              flash.now[:error] = I18n.t('requests.submit.error')
              logger.error "Request Submission #{@submission.errors.messages.as_json}"
            end
          end
        end
      end
    end

    # shim for pageable locations
    ## This feature no longer in use
    # def pageable
    #   request_params[:system_id] = sanitize(params[:system_id])
    #   @user = current_or_guest_user
    #   request_params[:user] = @user.uid
    #   unless params[:mfhd].nil?
    #     request_params[:mfhd] = sanitize(params[:mfhd])
    #   end
    #   @request = Requests::Request.new(request_params)
    #   if @request.has_pageable?
    #     respond_to do | format |
    #       format.json { render json: { pageable: true } }
    #       format.html { redirect_to "/requests/#{@request.system_id}" }
    #     end
    #   ## This clause should go away when this systems is in production for all request types
    #   else
    #     respond_to do | format |
    #       format.json { render json: { pageable: false } }
    #       format.html { redirect_to "https://library.princeton.edu/requests/#{@request.system_id}" }
    #     end
    #   end
    # end

    private

      # trusted params
      def request_params
        params.permit(:id, :system_id, :source, :mfhd, :user_name, :email, :user_barcode, :loc_code, :user, :requestable, :request, :barcode, :isbns).permit!
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
        patron
      end

      def access_patron(email, user_name)
        {
          last_name: user_name,
          active_email: email,
          barcode: 'ACCESS',
          barcode_status: 0
        }.with_indifferent_access
      end

      def sanitize_submission(params)
        params[:requestable].each do |requestable|
          params['user_supplied_enum'] = sanitize(requestable['user_supplied_enum']) if requestable.key? 'user_supplied_enum'
        end
        params
      end
  end
end
