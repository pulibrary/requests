module Requests
  class RequestMailer < ApplicationMailer
    # temporary changes issue 438
    include Requests::Bibdata

    def paging_email(submission)
      @submission = submission
      pickups = []
      @submission.items.each do |item|
        pickups.push(Requests::BibdataService.delivery_locations[item["pickup"]]["label"])
      end
      subject = I18n.t('requests.paging.email_subject') + ' for '
      subject += pickups.join(", ")
      destination_email = "trace@princeton.edu"
      cc_email = ["wange@princeton.edu", @submission.email]
      mail(to: destination_email,
           cc: cc_email,
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
      # temporary changes issue 438
      # cc_email = [@submission.email]
      cc_email = [@submission.email, I18n.t('requests.on_shelf.email')]
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexa.email_subject'), @submission.user_barcode))
    end

    def annexb_email(submission)
      @submission = submission
      destination_email = []
      @submission.items.each do |item|
        destination_email.push(I18n.t('requests.annexb.email')) if item["type"] == 'annexb'
      end
      cc_email = [@submission.email]
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexb.email_subject'), @submission.user_barcode))
    end

    def ppl_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.ppl.email')
      mail(to: destination_email,
           # temporary changes issue 438
           cc: [I18n.t('requests.on_shelf.email')],
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

    def lewis_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.lewis.email')
      mail(to: destination_email,
           # temporary changes issue 438
           cc: [I18n.t('requests.on_shelf.email')],
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.lewis.email_subject'), @submission.user_barcode))
    end

    def lewis_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.lewis.email_subject'), @submission.user_barcode))
    end

    # temporary changes issue 438
    def on_shelf_email(submission)
      location_email = get_location_contact_email(submission.items.first[:location_code])
      @submission = submission
      destination_email = I18n.t('requests.on_shelf.email')
      subject = "#{subject_line(I18n.t('requests.on_shelf.email_subject'), @submission.user_barcode)} (#{submission.items.first[:location_code].upcase}) #{submission.items.first[:call_number]}"
      mail(to: location_email,
           cc: destination_email,
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
      cc_email = [@submission.email]
      mail(to: destination_email,
           cc: cc_email,
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
      cc_email = [@submission.email]
      subject = I18n.t('requests.recap.email_subject')
      if @submission.user['user_barcode'] == 'ACCESS'
        cc_email = I18n.t('requests.recap.guest_email_destination')
        subject = I18n.t('requests.recap_guest.email_subject')
      end
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    def recap_email(submission)
      @submission = submission
      destination_email = @submission.email
      cc_email = [@submission.email]
      subject = I18n.t('requests.recap.email_subject')
      if @submission.user['user_barcode'] == 'ACCESS'
        cc_email = I18n.t('requests.recap.guest_email_destination')
        subject = I18n.t('requests.recap_guest.email_subject')
      end
      mail(to: destination_email,
           cc: cc_email,
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

    def recall_email(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.recall.email_subject'))
    end

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
