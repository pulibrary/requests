require 'faraday'

module Requests
  class BarcodeAuth
    attr_accessor :email
    attr_accessor :user_barcode
    attr_accessor :user_name

    include Requests::Bibdata

    # @option opts [User] :user current user object
    # @option opts [String] :source represents system that directed user to request form. i.e.

    def initialize(params)
      @barcode ||= params['request']['user_barcode']
      @email ||= params['request']['email']
      @user_name ||= params['request']['user_name']
      @valid = false
      @errors = []
      @sent = []
      handle
    end

    def handle
      r = patron(@barcode)
      if r['barcode'] == @barcode && r['barcode_status'] == 1
        @valid = true
      end
    end

    def valid?
      @valid
    end

    def submitted
      @sent
    end

    def errors
      @errors
    end

  end
end
