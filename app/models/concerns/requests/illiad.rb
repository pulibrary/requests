module Requests
  module Illiad
    # ILL related helpers
    extend ActiveSupport::Concern

    # accepts a @ctx object and formats it appropriately for ILL
    def illiad_request_url(ctx = nil, requestable)
      enum = nil
      chron = nil
      if requestable.enumerated?
        enum = requestable.item[:enum]
        chron = requestable.item[:chron]
      end
      "#{Requests.config[:ill_base]}?#{illiad_query_parameters(ctx, enum, chron)}"
    end

    ## below take from Umlaut's illiad service adaptor
    # https://github.com/team-umlaut/umlaut/blob/master/app/service_adaptors/illiad.rb
    # takes an existing openURL and illiad-izes it.
    # also attempts to handle the question of enumeration.
    def illiad_query_parameters(request, enum = nil, chron = nil)
      metadata = request.referent.metadata
      qp = {}
      qp['genre'] = metadata['genre']
      if metadata['aulast']
        qp["rft.aulast"] = metadata['aulast']
        qp["rft.aufirst"] = [metadata['aufirst'], metadata["auinit"]].find { |a| a.present? }
      else
        qp["rft.au"] = metadata["au"]
      end
      ## Possible enumeration values
      qp['volume'] = enum unless enum.nil?
      qp['issue']  = chron unless chron.nil?
      # qp['month']     = get_month(request.referent)
      qp['issn'] = metadata['issn'] unless metadata['issn'].nil?
      qp['isbn'] = metadata['isbn'] unless metadata['isbn'].nil?
      qp['stitle'] = metadata['stitle'] unless metadata['stitle'].nil?
      qp['sid'] = sid_for_illiad(request)
      qp['rft.date'] = metadata['date'] unless metadata['date'].nil?
      qp['atitle'] = metadata['atitle']
      # ILLiad always wants 'title', not the various title keys that exist in OpenURL
      qp['title'] = [metadata['jtitle'], metadata['btitle'], metadata['title']].find { |a| a.present? }
      # For some reason these go to ILLiad prefixed with rft.
      qp['rft.pub'] = metadata['pub']
      qp['rft.place'] = metadata['place']
      qp['rft.edition'] = metadata['edition']
      qp['rft_id'] = get_oclcnum(request.referent)
      # Genre normalization. ILLiad pays a lot of attention to `&genre`, but
      # doesn't use actual OpenURL rft_val_fmt
      if request.referent.format == "dissertation"
        qp['genre'] = 'dissertation'
      elsif qp['isbn'].present? && qp['genre'] == 'book' && qp['atitle'] && (qp['issn'].blank?)
        # actually a book chapter, not a book, fix it.
        qp['genre'] = 'bookitem'
      elsif qp['issn'].present? && qp['atitle'].present?
        # Otherwise, if there is an ISSN, we force genre to 'article', seems
        # to work best.
        qp['genre'] = 'article'
      elsif qp['genre'] == 'unknown' && qp['atitle'].blank?
        # WorldCat likes to send these, ILLiad is happier considering them 'book'
        qp['genre'] = "book"
      end
      # trim empty ones please
      qp.delete_if { |k, v| v.blank? }
      qp.to_query
    end

    # Grab a source label out of `sid` or `rfr_id`, add on our suffix.
    def sid_for_illiad(request)
      sid = request.referrer.identifiers.first || ""
      sid = sid.gsub(%r{\Ainfo\:sid/}, '')
      "#{sid}#{@sid_suffix}"
    end

    ## From https://github.com/team-umlaut/umlaut/blob/master/app/mixin_logic/metadata_helper.rb
    def get_oclcnum(rft)
      get_identifier(:info, "oclcnum", rft)
    end

    def get_lccn(rft)
      get_identifier(:info, "lccn", rft)
    end

    def get_identifier(type, sub_scheme, referent, options = {})
      options[:multiple] ||= false
      raise Exception.new("type must be :urn or :info") unless type == :urn or type == :info
      prefix = case type
                 when :info then "info:#{sub_scheme}/"
                 when :urn  then "urn:#{sub_scheme}:"
               end
      bare_identifier = nil
      identifiers = referent.identifiers.collect { |id| $1 if id =~ /^#{prefix}(.*)/ }.compact
      if (identifiers.blank? && ['lccn', 'oclcnum', 'isbn', 'issn', 'doi', 'pmid'].include?(sub_scheme))
        # try the referent metadata
        from_rft = referent.metadata[sub_scheme]
        identifiers = [from_rft] if from_rft.present?
      end
      if (options[:multiple])
        identifiers
      elsif (identifiers[0].blank?)
        nil
      else
        identifiers[0]
      end
    end
    ### end code from umlaut
  end
end
