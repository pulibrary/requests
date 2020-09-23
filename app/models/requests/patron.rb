require 'faraday'

module Requests
  class Patron
    attr_reader :user, :session, :patron, :errors

    delegate :guest?, to: :user

    def initialize(user:, session: {}, patron: nil)
      @user = user
      @session = session
      @errors = []
      # load the patron from bibdata unless we are passing it in
      @patron = patron || load_patron(user: user)
    end

    def barcode
      patron[:barcode]
    end

    def active_email
      patron[:active_email]
    end

    def first_name
      patron[:first_name]
    end

    def last_name
      patron[:last_name]
    end

    def netid
      patron[:netid]
    end

    def patron_id
      patron[:patron_id]
    end

    def patron_group
      patron[:patron_group]
    end

    def university_id
      patron[:university_id]
    end

    def source
      patron[:source]
    end

    def campus_authorized
      patron[:campus_authorized]
    end

    def blank?
      patron.empty?
    end

    def to_h
      patron
    end

    private

      def load_patron(user:)
        if !user.guest?
          patron = current_patron(user.uid)
          errors << "A problem occurred looking up your library account." if patron == false
          # Uncomment to fake being a non barcoded user
          # patron[:barcode] = nil
          patron || {}
        elsif session["email"].present? && session["user_name"].present?
          access_patron(session["email"], session["user_name"])
        else
          {}
        end
      end

      def current_patron(uid)
        return false unless uid
        begin
          patron_record = Faraday.get "#{Requests.config[:bibdata_base]}/patron/#{uid}"
        rescue Faraday::Error::ConnectionFailed
          Rails.logger.info("Unable to connect to #{Requests.config[:bibdata_base]}")
          return false
        end
        return false if patron_errors?(patron_record: patron_record, uid: uid)
        JSON.parse(patron_record.body).with_indifferent_access
      end

      def patron_errors?(patron_record:, uid:)
        return false if patron_record.status == 200
        if patron_record.status == 403
          Rails.logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                      "#{Requests.config[:bibdata_base]}/patron/#{uid}")
        elsif patron_record.status == 404
          Rails.logger.info("404 Patron #{uid} cannot be found in the Patron Data Service.")
        elsif patron_record.status == 500
          Rails.logger.info('Error Patron Data Service.')
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
  end
end
