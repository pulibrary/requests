module Requests
  class RequestMailer < ApplicationMailer
    def paging_email(submission)
      @submission = submission
      destination_email = "fstpage@princeton.edu"
      cc_email = [ "wange@princeton.edu", @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line(I18n.t('requests.paging.email_subject'), @submission.user_barcode))
    end

    def annexa_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      cc_email = [ @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line( I18n.t('requests.annexa.email_subject'), @submission.user_barcode))
    end

    def annexb_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      cc_email = [ @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line(I18n.t('requests.annexb.email_subject'), @submission.user_barcode))
    end

    def on_order_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      cc_email = [ @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line(I18n.t('requests.on_order.email_subject'), @submission.user_barcode))
    end

    def in_process_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      cc_email = [ @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line(I18n.t('requests.in_process.email_subject'), @submission.user_barcode))
    end

    def trace_email(submission)
      @submission = submission
      destination_email = I18n.t('requests.default.email_destination')
      cc_email = [ @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: subject_line(I18n.t('requests.trace.email_subject'), @submission.user_barcode))
    end

    def recap_email(submission)
      @submission = submission
      destination_email = @submission.email
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: I18n.t('requests.recap.email_subject'))
    end

    def recall_email(submission)
      @submission = submission
      destination_email = @submission.email
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           from: destination_email,
           subject: I18n.t('requests.recall.email_subject'))
    end

    private
    def subject_line(request_subject, barcode)
      if(barcode == 'ACCESS' || barcode == 'access') 
        "#{request_subject} - ACCESS"
      else
        request_subject
      end
    end

  end
end