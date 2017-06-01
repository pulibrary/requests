require 'openurl'

module Requests
  module Ctx
    extend ActiveSupport::Concern
    include OpenURL

    # returns an openurl CTX object
    def ctx
      @ctx ||= build_ctx
    end

    def openurl_ctx_kev
      ctx.kev
    end

    ## double check what are valid openURL formsts in the catatlog
    ## look at our choices and map
    # def format_to_openurl_genre(format)
    #   return 'book' if format == 'book'
    #   return 'journal' if format == 'serial'
    #   return 'journal' if format == 'journal'
    #   'unknown'
    # end

    private

      def build_ctx
        ctx = ContextObject.new
        id = doc['id']
        title = doc['title_citation_display'].first unless doc['title_citation_display'].nil?
        date = doc['pub_date_display'].first unless doc['pub_date_display'].nil?
        author = doc['author_citation_display'].first unless doc['author_citation_display'].nil?
        corp_author = doc['pub_citation_display'].first unless doc['pub_citation_display'].nil?
        publisher_info = doc['pub_citation_display'].first unless doc['pub_citation_display'].nil?
        edition = doc['edition_display'].first unless doc['edition_display'].nil?
        format = doc['format'].is_a?(Array) ? doc['format'].first.downcase.strip : doc['format'].downcase.strip
        if format == 'book'
          ctx.referent.set_format('book')
          ctx.referent.set_metadata('genre', 'book')
          ctx.referent.set_metadata('btitle', title)
          ctx.referent.set_metadata('title', title)
          ctx.referent.set_metadata('au', author)
          ctx.referent.set_metadata('aucorp', corp_author)
          # Place not easilty discernable in solr doc
          # ctx.referent.set_metadata('place', publisher_info)
          ctx.referent.set_metadata('pub', publisher_info)
          ctx.referent.set_metadata('edition', edition)
          ctx.referent.set_metadata('isbn', doc['isbn_s'].first) unless doc['isbn_s'].nil?
        elsif format =~ /journal/i # checking using include because institutions may use formats like Journal or Journal/Magazine
          ctx.referent.set_format('journal')
          ctx.referent.set_metadata('genre', 'journal')
          ctx.referent.set_metadata('atitle', title)
          ctx.referent.set_metadata('title', title)
          # use author display as corp author for journals
          ctx.referent.set_metadata('aucorp', author)
          ctx.referent.set_metadata('issn', doc['issn_s'].first) unless doc['issn_s'].nil?
        else
          ctx.referent.set_format('unknown') # do we need to do this?
          ctx.referent.set_metadata('genre', format)
          ctx.referent.set_metadata('title', title)
          ctx.referent.set_metadata('creator', author)
          ctx.referent.set_metadata('aucorp', corp_author)
          # place not discernable in solr doc
          # ctx.referent.set_metadata('place', publisher_info)
          ctx.referent.set_metadata('pub', publisher_info)
          ctx.referent.set_metadata('format', format)
          ctx.referent.set_metadata('issn', doc['issn_s'].first) unless doc['issn_s'].nil?
          ctx.referent.set_metadata('isbn', doc['isbn_s'].first) unless doc['isbn_s'].nil?
        end
        ## common metadata for all formats
        ctx.referent.set_metadata('date', date)
        # canonical identifier for the citation?
        ctx.referent.add_identifier("https://bibdata.princeton.edu/bibliographic/#{id}")
        # add pulsearch refererrer
        ctx.referrer.add_identifier('info:sid/pulsearch.princeton.edu:generator')
        ctx.referent.add_identifier("info:oclcnum/#{doc['oclc_s'].first}") unless doc['oclc_s'].nil?
        ctx.referent.add_identifier("info:lccn/#{doc['lccn_s'].first}") unless doc['lccn_s'].nil?
        ctx
      end
  end
end
