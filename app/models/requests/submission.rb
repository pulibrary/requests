require 'email_validator'

module Requests
  class SelectedItemsValidator < ActiveModel::Validator
    def mail_services
      ["paging", "annexa", "annexb", "trace", "on_order", "in_process"]
    end

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
        if mail_services.include?(selected["type"]) || selected["type"] == 'recall'
          if selected['pickup'].empty?
            record.errors[:items] << 'Please select a pickup location.'
          end
        end
        if selected["type"] == 'recap'
          if selected['item_id'].empty?
            record.errors[:items] << 'Item Cannot be Requested from Recap, see circulation desk.'
          else
            item_id = selected['item_id']
            if selected["delivery_mode_#{item_id}"].nil?
              record.errors[:items] << 'Please select a delivery type for your selected recap item'
            else
              delivery_type = selected["delivery_mode_#{item_id}"]
              if delivery_type == 'print' && selected['pickup'].empty?
                record.errors[:items] << 'Please selected a pickup location for your selected recap item'
              end
              if delivery_type == 'edd'
                if selected['edd_start_page'].empty?
                  record.errors[:items] << 'Please specify a starting page.'
                end
                if selected['edd_art_title'].empty?
                  record.errors[:items] << 'Please specify title for the selection you want digitized.'
                end
              end
            end
          end
        end
      end
    end
  end

  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 } #, format: { message: "Supply a Valid Email Address" } #, on: :submit
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 } # ,  format: { message: "Name Can't be Blank" } #, on: :submit
    validates :user_barcode, presence: true, length: { minimum: 5, maximum: 14 }, format: { with: /(^ACCESS$|^access$|^\d{14}$)/i, message: "Please supply a valid library barcode or type the value 'ACCESS'" }
    validate :item_validations #, presence: true, length: { minimum: 1 }, on: :submit

    def initialize(params)
      @user = params[:request]
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
    end

    def email
      @user[:email]
    end

    def source
      @user[:source]
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

    def id
      @bib[:id]
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