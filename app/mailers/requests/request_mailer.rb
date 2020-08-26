module Requests
  class RequestMailer < ApplicationMailer
    include Requests::Bibdata

    def paging_email(submission)
      @submission = submission
      pickups = @submission.items.map { |item| Requests::BibdataService.delivery_locations[item["pickup"]]["label"] }
      subject = I18n.t('requests.paging.email_subject', pickup_location: pickups.join(", "))
      destination_email = "fstpage@princeton.edu"
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def paging_confirmation(submission)
      @submission = submission
      pickups = @submission.items.map { |item| Requests::BibdataService.delivery_locations[item["pickup"]]["label"] }
      subject = I18n.t('requests.paging.email_subject', pickup_location: pickups.join(", "))
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def pres_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.pres.email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.pres.email_subject'), @submission.user_barcode))
    end

    def pres_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.pres.email_subject'), @submission.user_barcode))
    end

    def annexa_email(submission)
      @submission = submission
      destination_email = annexa_email_destinations(submission: @submission)
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexa.email_subject'), @submission.user_barcode))
    end

    def annexa_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexa.email_subject'), @submission.user_barcode))
    end

    def annexb_email(submission)
      @submission = submission
      destination_email = []
      @submission.items.each do |item|
        destination_email.push(I18n.t('requests.annexb.email')) if item["type"] == 'annexb'
      end
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexb.email_subject'), @submission.user_barcode))
    end

    def annexb_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexb.email_subject'), @submission.user_barcode))
    end

    def ppl_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.ppl.email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.ppl.email_subject'), @submission.user_barcode))
    end

    def ppl_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.ppl.email_subject'), @submission.user_barcode))
    end

    # temporary changes issue 438
    def on_shelf_email(submission)
      location_email = get_location_contact_email(submission.items.first[:location_code])
      @submission = submission
      # Location and destination are the same forthe moment
      # destination_email = I18n.t('requests.on_shelf.email')
      subject = "#{subject_line(I18n.t('requests.on_shelf.email_subject'), @submission.user_barcode)} (#{submission.items.first[:location_code].upcase}) #{submission.items.first[:call_number]}"
      mail(to: location_email,
           # cc: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    # temporary changes issue 438
    def on_shelf_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = "#{Requests::BibdataService.delivery_locations[@submission.items.first['pickup']]['label']} #{I18n.t('requests.on_shelf.email_subject_patron')}"
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def on_order_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.on_order.email_subject'), @submission.user_barcode))
    end

    def on_order_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.on_order.email_subject'), @submission.user_barcode))
    end

    def in_process_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.in_process.email_subject'), @submission.user_barcode))
    end

    def in_process_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.in_process.email_subject'), @submission.user_barcode))
    end

    def trace_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.trace.email_subject'), @submission.user_barcode))
    end

    def trace_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.trace.email_subject'), @submission.user_barcode))
    end

    def recap_no_items_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.recap_no_items.email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.recap_no_items.email_subject'), @submission.user_barcode))
    end

    def recap_no_items_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.recap.email_subject')
      if @submission.access_only?
        cc_email = I18n.t('requests.recap.guest_email_destination')
        subject = I18n.t('requests.recap_guest.email_subject')
      end
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    def digitize_email(submission)
      # TODO: what should we do here
    end

    def digitize_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.digitize.email_subject')
      mail(to: destination_email,
           from: I18n.t('requests.digitize.email_from'),
           subject: subject)
    end

    def recap_email(submission)
      # only send an email to the libraries if this is a barcode user request
      return unless submission.access_only?
      @submission = submission
      destination_email = I18n.t('requests.recap.guest_email_destination')
      subject = I18n.t('requests.recap_guest.email_subject')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    def recap_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.recap.email_subject')
      subject = I18n.t('requests.recap_guest.email_subject') if @submission.access_only?
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    def recap_edd_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.recap_edd.email_subject')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    # goes directly to voyager
    def recall_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.recall.email_subject'))
    end

    # depracated - TODO: clean up
    def scsb_recall_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.recap.scsb_recall_destination')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.recall.staff_email_subject'))
    end

    def service_error_email(services)
      @services = services
      destination_email = I18n.t('requests.error.service_error_email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.error.service_error_subject'))
    end

    def invalid_illiad_patron_email(user_attributes, transaction_attributes)
      @user_attributes = user_attributes
      @transaction_attributes = transaction_attributes
      destination_email = I18n.t('requests.digitize.invalid_patron.email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.digitize.invalid_patron.subject'))
    end

    private

      def annexa_email_destinations(submission:)
        annexa_items(submission: submission).map do |item|
          if item["location_code"] == 'anxadoc'
            I18n.t('requests.anxadoc.email')
          else
            I18n.t('requests.annexa.email')
          end
        end
      end

      def annexa_items(submission:)
        submission.items.select { |item| item["type"] == 'annexa' }
      end

      def subject_line(request_subject, barcode)
        if barcode == 'ACCESS' || barcode == 'access'
          "#{request_subject} - ACCESS"
        else
          request_subject
        end
      end
  end
end
