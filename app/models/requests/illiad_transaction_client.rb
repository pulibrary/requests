# frozen_string_literal: true

# require 'faraday'
# require 'faraday-cookie_jar'

module Requests
  class IlliadTransactionClient < IlliadClient
    attr_reader :patron, :bib, :item, :note, :illiad_transaction_status, :attributes

    def initialize(patron:, bib:, item:)
      super()
      @patron = patron
      @bib = bib
      @item = item
      @note = ["Digitization Request", item["edd_note"]].join(": ")&.truncate(4000)
      @illiad_transaction_status = "Awaiting Article Express Processing"
      @attributes = map_metdata
    end

    def create_request
      patron_client = Requests::IlliadPatron.new(patron)
      illiad_patron = patron_client.illiad_patron
      illiad_patron = patron_client.create_illiad_patron if illiad_patron.blank?
      return nil if illiad_patron.blank?
      Requests::RequestMailer.send("invalid_illiad_patron_email", patron_client.attributes, attributes).deliver_now unless validate_illiad_patron(illiad_patron)
      transaction = post_json_response(url: 'ILLiadWebPlatform/transaction', body: attributes.to_json)
      post_json_response(url: "ILLiadWebPlatform/transaction/#{transaction['TransactionNumber']}/notes", body: "{ \"Note\" : \"#{note}\", \"NoteType\" : \"Staff\" }") if transaction.present?
      transaction
    end

    private

      def map_metdata
        {
          "Username" => patron.netid, "TransactionStatus" => illiad_transaction_status,
          "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"),
          "WantedBy" => "Yes, until the semester's", # note creation fails if we use any other text value
          "PhotoItemAuthor" => bib["author"]&.truncate(100), "PhotoArticleAuthor" => item["edd_author"]&.truncate(100), "PhotoJournalTitle" => bib["title"]&.truncate(255),
          "PhotoItemPublisher" => item["edd_publisher"]&.truncate(40), "ISSN" => bib["isbn"], "CallNumber" => item["edd_call_number"]&.truncate(255),
          "PhotoJournalInclusivePages" => pages&.truncate(30), "CitedIn" => "#{Requests.config[:pulsearch_base]}/catalog/#{bib['id']}", "PhotoJournalYear" => item["edd_date"],
          "PhotoJournalVolume" => volume_number(item), "PhotoJournalIssue" => item["edd_issue"]&.truncate(30),
          "ItemInfo3" => item["edd_volume_number"]&.truncate(255), "ItemInfo4" => item["edd_issue"]&.truncate(255),
          "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => item["edd_oclc_number"]&.truncate(32),
          "DocumentType" => genre, "Location" => item["edd_location"],
          "PhotoArticleTitle" => item["edd_art_title"]&.truncate(250)
        }
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

      def validate_illiad_patron(patron)
        cleared = patron["Cleared"]
        cleared == "Yes"
      end

      def volume_number(item)
        vol = []
        vol << item["user_supplied_enum"] if item["user_supplied_enum"].present?
        vol << item["edd_volume_number"] if item["edd_volume_number"].present?
        vol.join(', ')&.truncate(30)
      end
  end
end
