require 'email_validator'

module Requests
  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { maximum: 50 }, on: :submit
    validates :f_name, presence: true, length: { maximum: 50 }, on: :submit
    validates :l_name, presence: true, length: { maximum: 50 }, on: :submit
    validates :user_barcode, presence: true, length: { maximum: 14 }, on: :submit
    validates :items, presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params)
      @user = params[:request]
      @items = params[:requestable]
    end

    def email
      @user[:email]
    end

    def f_name
      @user[:f_name]
    end

    def l_name
      @user[:l_name]
    end

    def user_barcode
      @user[:user_barcode]
    end

    def items
      @items
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