module Requests
  module Aeon
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    # for use with only non-voyager thesis records
    def aeon_mapped_params
      params = {
        Action: '10',
        Form: '21',
        ItemTitle: title.truncate(247),
        ItemAuthor: author,
        ItemDate: pub_date,
        ItemVolume: sub_title
      }
      params[:ItemNumber] = item[:barcode] if barcode?
      params[:genre] = 'thesis' if thesis?
      params.merge! aeon_basic_params
      params.reject { |_k, v| v.nil? }
    end

    ## params shared by both voyager and non-voyager aeon requests
    def aeon_basic_params
      params = {
        ReferenceNumber: bib[:id],
        CallNumber: call_number,
        Site: site,
        Location: shelf_location_code,
        SubLocation: sub_location,
        ItemInfo1: I18n.t("requests.aeon.access_statement")
      }
      params.reject { |_k, v| v.nil? }
    end

    # accepts the base Openurl Context Object and formats it appropriately for Aeon
    def aeon_request_url(ctx = nil)
      "#{Requests.config[:aeon_base]}/OpenURL?#{aeon_openurl(ctx)}"
    end

    # returns encoded OpenURL string for voyager derived records
    def aeon_openurl(ctx)
      if item_data?
        ctx.referent.set_metadata('iteminfo5', item[:id].to_s)
      else
        ctx.referent.set_metadata('iteminfo5', nil)
      end
      if enumerated?
        ctx.referent.set_metadata('volume', item[:enum])
        ctx.referent.set_metadata('issue', item[:chron]) if item[:chron].present?
      elsif holding.first.last['location_has']
        ctx.referent.set_metadata('volume', holding.first.last['location_has'].first)
        ctx.referent.set_metadata('issue', nil)
      else
        ctx.referent.set_metadata('volume', nil)
        ctx.referent.set_metadata('issue', nil)
      end
      aeon_params = aeon_basic_params
      aeon_params[:ItemNumber] = barcode if barcode?
      ## returned mashed together in an encoded string
      "#{ctx.kev}&#{aeon_params.to_query}"
    end

    # this non_voyager? method has an OL dependency
    def non_voyager?(holding_id)
      if holding_id == 'thesis'
        true
      else
        false
      end
    end

    def site
      if holding.key? 'thesis'
        'MUDD'
      elsif !location[:holding_library].nil?
        if location['holding_library']['code'] == 'eastasian' && location['aeon_location'] == true
          'EAL'
        elsif location['holding_library']['code'] == 'marquand' && location['aeon_location'] == true
          'MARQ'
        elsif location['holding_library']['code'] == 'mudd' && location['aeon_location'] == true
          'MUDD'
        else
          'RBSC'
        end
      elsif location['library']['code'] == 'eastasian' && location['aeon_location'] == true
        'EAL'
      elsif location['library']['code'] == 'marquand'  && location['aeon_location'] == true
        'MARQ'
      elsif location['library']['code'] == 'mudd'
        'MUDD'
      else
        "RBSC"
      end
    end

    private

      def call_number
        holding.first.last['call_number']
      end

      def pub_date
        bib[:pub_date_start_sort]
      end

      def shelf_location_code
        holding.first.last['location_code']
      end

      ## These two params were from Primo think they both go to
      ## location and location_note in our holdings statement
      def sub_title
        holding.first.last[:location]
      end

      def sub_location
        holding.first.last[:location_note]&.first
      end
      ### end special params

      def title
        "#{bib[:title_display]}#{genre}"
      end

      ## Don T requested this be appended when present
      def genre
        " [ #{bib[:form_genre_display].first} ]" unless bib[:form_genre_display].nil?
      end

      def author
        bib[:author_display]&.join(" AND ")
      end
  end
end
