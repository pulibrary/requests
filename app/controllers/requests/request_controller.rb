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
      system_id = sanitize(params[:system_id])
      source = sanitize(params[:source]) if params[:source].present?
      mfhd = sanitize(params[:mfhd]) if params[:mfhd].present?

      @user = current_or_guest_user
      @patron = patron(user: @user)
      @mode = mode
      @title = "Request ID: #{system_id}"

      # needed to see if we can suppress login for this item
      @request = Requests::Request.new(system_id: system_id, mfhd: mfhd, source: source, user: @user)
      ### redirect to Aeon non-voyager items or single Aeon requestable
      if @request.thesis? || @request.numismatics?
        redirect_to "#{Requests.config[:aeon_base]}?#{@request.requestable.first.aeon_mapped_params.to_query}"
      elsif @request.single_aeon_requestable?
        redirect_to @request.first_filtered_requestable.aeon_request_url(@request.ctx)
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
        format.js do
          valid = @submission.valid?
          @services = @submission.process_submission if valid
          if valid && @submission.service_errors.blank?
            respond_to_submit_success(@submission)
          elsif valid # submission was valid, but service failed
            respond_to_service_error(@services)
          else
            respond_to_validation_error(@submission)
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
    #   if @request.any_pageable?
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

      def patron(user:)
        if params[:request].present?
          email = format_email(sanitize(params[:request][:email]))
          user_name = sanitize(params[:request][:user_name])
        end

        if !user.guest?
          patron = current_patron(user.uid)
          flash.now[:error] = "A problem occurred looking up your library account." if patron == false
          patron
        elsif email && user_name
          access_patron(email, user_name)
        end
      end

      def mode
        return 'standard' if params[:mode].nil?
        sanitize(params[:mode])
      end

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
        return false if patron_errors?(patron_record: patron_record, uid: uid)
        JSON.parse(patron_record.body).with_indifferent_access
      end

      def patron_errors?(patron_record:, uid:)
        return false if patron_record.status == 200
        if patron_record.status == 403
          logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                      "#{Requests.config[:bibdata_base]}/patron/#{uid}")
        elsif patron_record.status == 404
          logger.info("404 Patron #{uid} cannot be found in the Patron Data Service.")
        elsif patron_record.status == 500
          logger.info('Error Patron Data Service.')
        end
        true
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

      def respond_to_submit_success(submission)
        flash.now[:success] = submission.success_messages.join(' ')
        # TODO: Why does this go into an infinite loop
        # logger.info "#Request Submission - #{submission.as_json}"
        logger.info "Request Sent"
        return if submission.service_types.include? 'bd' # emails already sent
        submission.service_types.each do |type|
          Requests::RequestMailer.send("#{type}_email", submission).deliver_now unless type == 'recap_edd'
          Requests::RequestMailer.send("#{type}_confirmation", submission).deliver_now if ['on_shelf', 'on_order', 'in_process', 'pres', 'recap_no_items', 'lewis', 'ppl', 'paging', 'recap', 'recap_edd', 'annexa', 'digitize'].include? type
          Requests::RequestMailer.send("scsb_recall_email", submission).deliver_now if type == 'recall' && submission.scsb?
        end
      end

      def respond_to_service_error(services)
        flash.now[:error] = I18n.t('requests.submit.service_error')
        logger.error "Request Service Error"
        Requests::RequestMailer.send("service_error_email", services).deliver_now
      end

      def respond_to_validation_error(submission)
        flash.now[:error] = I18n.t('requests.submit.error')
        logger.error "Request Submission #{submission.errors.messages.as_json}"
      end
  end
end
