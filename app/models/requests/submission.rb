require 'email_validator'

module Requests
  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 } #, on: :submit
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 } #, on: :submit
    validates :user_barcode, presence: true, length: { minimum: 5, maximum: 14 } #, on: :submit
    validates :items, presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params)
      @user = params[:request]
      @items = params[:requestable]
      @bib = params[:bib]
    end

    def email
      @user[:email]
    end

    def user_name
      @user[:user_name]
    end

    def user_barcode
      @user[:user_barcode]
    end

    def items
      @items.select do |item| 
        unless item[:selected].nil?
          item
        end
      end
    end

    def bib
      @bib
    end

    def service_type
      types = []
      @items.each do |item|
        types << item[:type]
      end
      types.uniq!
      types.first
    end
  end
end