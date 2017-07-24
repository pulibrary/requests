require 'faraday'
require 'cobravsmongoose'

module Requests
  class IllToEdd
    include Requests::Illiad
    include Requests::Bibdata
    include Requests::Scsb

    def initialize(params)
      @params = params
      @errors = []
      @submission_params = {}
      @bib = { id: nil, title: "" }
      @user = { user_name: nil,
                user_barcode: nil,
                email: nil
              }
      @item = { type: 'edd',
                item_id: nil,
                call_number: "",
                edd_author: "",
                edd_art_title: "",
                pickup: "",
                edd_end_page: nil,
                edd_start_page: nil,
                edd_issue: "",
                location_code: "",
                edd_note: "",
                edd_volume_number: ""
              }
      handle
    end

    def handle
      validate_tn
      r = get_response(@params)
      unless r.status == 200
        @errors << { error: "Error retrieving ILLiad transaction." }
      end
      illiad_response = JSON.parse(r.body)
      bib_record = get_bibrec_by_barcode(illiad_response['ILLNumber'])
      system_id = bib_record[:fields].select {|field| field["001"] }.first["001"]
      item_subfields = bib_record[:fields].select {|field| field["876"] }.first["876"]
      @item[:item_id] = item_subfields[:subfields].select {|subfield| subfield["0"] }.first["0"]
      # submission params
      map_solr_to_bib(solr_doc(system_id))
      map_illiad_to_item(illiad_response)
      map_patron_to_user(patron(illiad_response['Username']))
    end

    def response
      request_params = scsb_param_mapping(@bib.with_indifferent_access, @user.with_indifferent_access, @item.with_indifferent_access)
      # scsb_request(request_params)
    end

    def map_patron_to_user(patron)
      @user[:user_name] = patron[:netid]
      @user[:user_barcode] = patron[:barcode]
      @user[:email] = patron[:active_email]
    end

    def map_illiad_to_item(illiad_response)
      issue = [illiad_response['PhotoJournalIssue'], illiad_response['PhotoJournalMonth'], illiad_response['PhotoJournalYear']]
      page_range = illiad_response['PhotoJournalInclusivePages'].split("-")
      @item[:barcode] = illiad_response['ILLNumber']
      @item[:call_number] = illiad_response['CallNumber']
      @item[:edd_author] = illiad_response['PhotoArticleAuthor']
      @item[:edd_art_title] = illiad_response['PhotoArticleTitle']
      @item[:edd_volume_number] = illiad_response['PhotoJournalVolume']
      @item[:edd_note] = illiad_response['FlagNote']
      @item[:edd_issue] = issue.compact.join(" ")
      @item[:edd_start_page] = page_range[0]
      @item[:edd_end_page] = page_range[1]
      @item[:selected] = true
      @item[:"delivery_mode_#{@item[:item_id]}"] = "recap_edd"
    end

    def map_solr_to_bib(solr_doc)
      @bib[:id] = solr_doc[:id]
      @bib[:title] = solr_doc[:title_display]
    end

    def bib
      @bib
    end

    def user
      @user
    end

    def item
      @item
    end

    def errors
      @errors
    end

    def submission_params
      @submission_params
    end

    def validate_tn
      integer = (/^\d+$/)
      unless @params['transaction_number'] =~ integer
        @errors << { error: "Invalid transaction number." }
      end
    end

  end
end
