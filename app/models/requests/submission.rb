require 'email_validator'

module Requests

  class SelectedItemsValidator < ActiveModel::Validator
    def validate(record)
      unless record.items.size >= 1
        record.errors[:items] << 'Please Select an Item to Request!'
      end
      record.items.each do |selected|
        if selected.key? 'user_supplied_enum' 
          if selected['user_supplied_enum'].empty?
            record.errors[:items] << 'Please Fill in additional volume information'
          end
        end
      end
    end
  end

  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 } #, on: :submit
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 } #, on: :submit
    validates :user_barcode, presence: true, length: { minimum: 5, maximum: 14 }, format: { with: /(^ACCESS$|^\d{14}$)/i, message: "Supply a valid library barcode or type the value 'ACCESS'" }
    validate :item_validations #, presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params)
      @user = params[:request]
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
    end

    def email
      @user[:email]
    end

    def user_name
      @user[:user_name]
    end

    def items
      @items
    end

    def selected_items(requestable_list)
      requestable_list.select{ |r| r unless r[:selected] == 'false' }
    end

    def item_validations
      validates_with Requests::SelectedItemsValidator
    end

    def user_barcode
      @user[:user_barcode]
    end

    def bib
      @bib
    end

    # def selected_items
    #   selected_items = @items.select{ |r| r unless r[:selected].nil? }
    #   errors.add(:items, "No Items Selected for request") unless selected_items.size >= 1
    # end

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