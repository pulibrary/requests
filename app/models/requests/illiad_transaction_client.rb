# frozen_string_literal: true

# require 'faraday'
# require 'faraday-cookie_jar'

module Requests
  class IlliadTransactionClient < IlliadClient
    attr_reader :user, :bib, :item, :note, :illiad_transaction_status

    def initialize(user:, bib:, item:)
      super()
      @user = user
      @bib = bib
      @item = item
      @note = "Digitization Request"
      @illiad_transaction_status = "Awaiting Catalog Request Processing"
    end

    def create_request
      patron_client = Requests::IlliadPatron.new(user)
      patron_client.create_illiad_patron if patron_client.illiad_patron.blank?
      transaction = post_json_response(url: 'ILLiadWebPlatform/transaction', body: map_metdata)
      # TODO: I can not create a note for the moment...
      # transaction_note = post_json_response(url: "ILLiadWebPlatform/transaction/#{transaction['TransactionNumber']}/notes", body: "{ \"Note\" : \"#{note}\", \"NoteType\" : \"Staff\" }") if transaction.present?
      post_json_response(url: "ILLiadWebPlatform/transaction/#{transaction['TransactionNumber']}/notes", body: "{ \"Note\" : \"#{note}\", \"NoteType\" : \"Staff\" }") if transaction.present?
      transaction
    end

    private

      def map_metdata
        {
          "Username" => user["netid"], "TransactionStatus" => illiad_transaction_status,
          "RequestType" => "Loan", "ProcessType" => "DocDel", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"),
          "WantedBy" => "Yes, until the semester's", # note creation fails if we use any other text value
          "LoanAuthor" => bib["author"]&.truncate(100), "LoanTitle" => bib["title"]&.truncate(255), "LoanPublisher" => item["edd_publisher"]&.truncate(50), "LoanDate" => item["edd_issue"]&.truncate(30),
          "ISSN" => bib["isbn"], "CallNumber" => item["edd_call_number"]&.truncate(255), "PhotoJournalInclusivePages" => pages&.truncate(30),
          "CitedIn" => "#{Requests.config[:pulsearch_base]}/catalog/#{bib['id']}",
          "PhotoJournalVolume" => item["edd_volume_number"]&.truncate(30), "PhotoJournalIssue" => item["edd_issue"]&.truncate(30),
          "ItemInfo3" => item["edd_volume_number"]&.truncate(255), "ItemInfo4" => item["edd_issue"]&.truncate(255), "SpecialInstructions" => [@note, item["edd_note"]].join(": ")&.truncate(255),
          "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => item["edd_oclc_number"]&.truncate(32),
          "DocumentType" => genre, "Location" => item["edd_location"],
          "PhotoArticleTitle" => item["edd_art_title"]&.truncate(250)
        }.to_json
      end

      def pages
        "#{item['edd_start_page']}-#{item['edd_end_page']}"
      end

      def genre
        case item["edd_genre"]
        when "article"
          "Article"
        when "bookitem"
          "Book Chapter"
        when "dissertation"
          "Thesis"
        else
          "Book"
        end
      end
  end
end
