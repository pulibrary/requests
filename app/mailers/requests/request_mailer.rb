module Requests
  class RequestMailer < ApplicationMailer
    def paging_email(submission)
      @submission = submission
      pickups = []
      @submission.items.each do |item|
        pickups.push(DELIVERY_LOCATIONS[item["pickup"]]["label"])
      end
      subject = I18n.t('requests.paging.email_subject') + ' for '
      subject += pickups.join(", ")
      destination_email = "fstpage@princeton.edu"
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
      destination_email = []
      @submission.items.each do |item|
        if item["type"] == 'annexa'
          item["location_code"] == 'anxadoc' ? destination_email.push(I18n.t('requests.anxadoc.email')) : destination_email.push(DELIVERY_LOCATIONS[item["pickup"]]["contact_email"])
        end
      end
      cc_email = [@submission.email]
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexa.email_subject'), @submission.user_barcode))
    end

    def annexb_email(submission)
      @submission = submission
      destination_email = []
      @submission.items.each do |item|
        if item["type"] == 'annexb'
          destination_email.push(DELIVERY_LOCATIONS[item["pickup"]]["contact_email"])
        end
      end
      cc_email = [@submission.email]
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annexb.email_subject'), @submission.user_barcode))
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

    def recall_email(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.recall.email_subject'))
    end

    def scsb_recall_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
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

      def subject_line(request_subject, barcode)
        if barcode == 'ACCESS' || barcode == 'access'
          "#{request_subject} - ACCESS"
        else
          request_subject
        end
      end
  end
end
