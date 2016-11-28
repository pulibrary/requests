module Requests
  module Illiad
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def submit_request(submission)
    end

    # implement solr_doc to ILL friendly openURLs
    def ill_param_mappings
      params = {
        'Action' => '10',
        'Form' => '30',
        'au' => bib[:author_citation_display],
        'genre' => openurl_genre(bib[:format].first),
        'rfe_dat' =>  bib[:id],
        'rft.place' => bib[:pub_created_display].first,
        'rft.pub' => bib[:pub_created_display].first,
        'sid' => 'pulsearch.princeton.edu',
        'title' => bib[:title_display],
        'year'=> bib[:pub_date_display].first,
      }
      params.reject { |k,v| v.nil? }
    end

    def openurl_genre(format)
      if format == 'Book'
        'book'
      elsif format == 'Journal'
        'journal'
      elsif
        'other'
      end
    end

  end
end