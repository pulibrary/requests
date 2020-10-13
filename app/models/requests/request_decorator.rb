module Requests
  class RequestDecorator
    delegate :patron, :requestable, :first_filtered_requestable, :sorted_requestable, :filtered_sorted_requestable,
             :ctx, :system_id, :language, :mfhd, :source, :holdings, :default_pick_ups, :fill_in_eligible,
             :serial?, :borrow_direct_eligible?, :any_loanable_copies?, :requestable?, :all_items_online?,
             :any_will_submit_via_form?, :thesis?, :numismatics?, :single_aeon_requestable?, :single_item_request?,
             :user_name, :email, # passed to request as login options on the request form
             to: :request
    delegate :content_tag, :hidden_field_tag, :concat, to: :view_context

    alias bib_id system_id

    attr_reader :request, :view_context
    def initialize(request, view_context)
      @request = request
      @view_context = view_context
    end

    def catalog_url
      "/catalog/#{system_id}"
    end

    # rubocop:disable Rails/OutputSafety
    def patron_message
      return "" if (patron.campus_authorized && !first_filtered_requestable.etas?) || patron.guest?

      "<div class='alert alert-warning'>#{patron_message_internal}</div>".html_safe
    end

    def hidden_fields
      hidden_request_tags = ''
      hidden_request_tags += hidden_field_tag "bib[id]", "", value: bib_id
      request.display_metadata.each do |key, value|
        hidden_request_tags += hidden_field_tag "bib[#{key}]", "", value: value
      end
      hidden_request_tags.html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def format_brief_record_display
      params = request.display_metadata
      content_tag(:dl, class: "dl-horizontal") do
        params.each do |key, value|
          if value.present? && display_label[key].present?
            concat content_tag(:dt, display_label[key].to_s)
            concat content_tag(:dd, value.first.to_s, lang: request.language.to_s, id: display_label[key].gsub(/[^0-9a-z ]/i, '').downcase.to_s)
          end
        end
      end
    end

    private

      def patron_message_internal
        if first_filtered_requestable.etas?
          "We currently cannot lend this item" +
            if first_filtered_requestable.etas_limited_access
              " from our ReCAP partner collection due to changes in copyright restrictions."
            else
              ", but you may view an online copy via the <a href='#{catalog_url}'>link in the record page</a>"
            end
        elsif patron.pick_up_only?
          "You are only currently authorized to utilize our book <a href='https://library.princeton.edu/services/book-pick-up'>pick-up service</a>. Please consult with your Department if you would like to book time to spend in our libraries using our <a href='https://library.princeton.edu/services/study-browse'>study-browse service</a>."
        elsif !patron.guest? && !patron.campus_authorized
          msg = "You are not currently authorized for on-campus services at the Library. Please consult with your Department if you believe you should have access to these services."
          msg += "  If you would like to have access to pick-up books <a href='https://ehs.princeton.edu/COVIDTraining'>please complete the mandatory COVID-19 training</a>." if patron.training_eligable?
          msg
        end
      end

      def display_label
        {
          author: "Author/Artist",
          title: "Title",
          date: "Published/Created",
          id: "Bibliographic ID",
          mfhd: "Holding ID (mfhd)"
        }.with_indifferent_access
      end
  end
end
