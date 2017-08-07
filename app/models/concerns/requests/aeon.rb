module Requests
  module Aeon
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    # for use with only non-voyager visuals and thesis records
    def aeon_mapped_params
      params = {
        Action: '10',
        Form: '21',
        ItemTitle: title,
        ItemAuthor: author,
        ItemDate: pub_date,
        ItemVolume: sub_title
      }
      if barcode?
        params[:ItemNumber] = item[:barcode]
      end
      if thesis?
        params[:genre] = 'thesis'
      end
      params.merge! aeon_basic_params
      params.reject { |k, v| v.nil? }
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
      params.reject { |k, v| v.nil? }
    end

    # accepts the base Openurl Context Object and formats it appropriately for Aeon
    def aeon_request_url(ctx = nil)
      "#{Requests.config[:aeon_base]}/OpenURL?#{aeon_openurl(ctx)}"
    end

    # returns encoded OpenURL string for voyager derived records
    def aeon_openurl(ctx)
      if has_item_data?
        ctx.referent.set_metadata('iteminfo5', item[:id].to_s)
      end
      if enumerated?
        ctx.referent.set_metadata('volume', item[:enum])
        if item[:chron].present?
          ctx.referent.set_metadata('issue', item[:chron])
        end
      end
      aeon_params = aeon_basic_params
      if barcode?
        aeon_params[:ItemNumber] = barcode
      end
      ## returned mashed together in an encoded string
      "#{ctx.kev}&#{aeon_params.to_query}"
    end

    # this non_voyager? method has an OL dependency
    def non_voyager?(holding_id)
      if holding_id == 'thesis'
        return true
      elsif holding_id == 'visuals'
        return true
      else
        return false
      end
    end

    def site
      if holding.key? 'thesis'
        'MUDD'
      elsif holding.key? 'visuals'
        'RBSC'
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
        unless bib[:call_number_display].nil?
          bib[:call_number_display].first
        end
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
        unless holding.first.last[:location_note].nil?
          holding.first.last[:location_note].first
        end
      end
      ### end special params

      def title
        "#{bib[:title_display]}#{genre}"
      end

      ## Don T requested this be appended when present
      def genre
        unless bib[:form_genre_display].nil?
          " [ #{bib[:form_genre_display].first} ]"
        end
      end

      def author
        unless bib[:author_display].nil?
          bib[:author_display].join(" AND ")
        end
      end
  end
end
