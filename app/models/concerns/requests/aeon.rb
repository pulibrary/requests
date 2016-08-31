module Requests
  module Aeon
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    def submit_request(submission)
    end

    def aeon_mapped_params(bib, holding)
      ## For theses
      # 'ReferenceNumber' => $this->getRecordID(),
      #   'Site' => 'MUDD',
      #   'CallNumber' => $this->getOtherCallNum(),
      #   'Location' => 'mudd',
      #   'Action' => '10',
      #   'Form' => '21',
      #   'ItemTitle' => $this->getTitle(),
      #   'ItemAuthor' => $this->getCreator(),
      #   'ItemDate' => $this->getCreationDate(),
      #   'ItemInfo1' => 'Reading Room Access Only',
      # For graphic arts
      # 'ReferenceNumber' => $this->getRecordID(),
      #   'Site' => 'RBSC',
      #   'CallNumber' => $this->getOtherCallNum(),
      #   'Location' => 'ga',
      #   'Action' => '10',
      #   'Form' => '21',
      #   'ItemTitle' => $this->getTitle() . " [" . $this->getGenre() . "]",
      #   'ItemVolume' => $this->getOtherSubTitle(),
      #   'SubLocation' => $this->getOtherItemInfoFour(),
      #   'ItemInfo1' => 'Reading Room Access Only',
      #   'ItemAuthor' => $this->getCreator()
      params = {
        ReferenceNumber: bib[:id],
        Site: site(holding),
        Action: '10',
        Form: '21',
        CallNumber: call_number(holding),
        Location: shelf_location_code(holding),
        ItemTitle: title(bib),
        ItemAuthor: author(bib),
        ItemDate: pub_date(bib),
        ItemVolume: sub_title(holding),
        SubLocation: sub_location(holding),
        ItemInfo1: I18n.t("requests.aeon.access_statement"),
        # ItemNumber: barcode(item) 
      }
      params.reject { |k,v| v.nil? }
    end

    def non_voyager?(holding_id)
      if holding_id == 'thesis' 
        return true
      elsif holding_id == 'visuals'
        return true
      else
        return false
      end
    end

    ### need to get site codes for EAL and Marquand
    def site(holding)
      unless holding["thesis"].nil?
        "MUDD"
      else
        "RBSC"
      end
    end

    def call_number(holding)
      holding.first.last[:call_number]
    end

    def pub_date(bib)
      bib[:pub_date_start_sort]
    end

    def shelf_location_code(holding)
      holding.first.last[:location_code]
    end

    ## These two params were from Primo think they both go to
    ## location and location_note in our holdings statement
    def sub_title(bib)
      holding.first.last[:location]
    end

    def sub_location(bib)
      holding.first.last[:location_note]
    end
    ### end special params

    def title(bib)
      "#{bib[:title_display]} #{genre(bib)}"
    end

    ## Don T requested this for visuals
    def genre(bib)
      unless bib[:form_genre_display].nil?
        "[ #{bib[:form_genre_display].first} ]"
      end
    end

    def author(bib)
      unless bib[:author_display].nil?
        bib[:author_display].join(" AND ")
      end
    end

  end
end