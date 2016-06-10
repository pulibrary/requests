module Requests
  class RequestMailer < ApplicationMailer
    def paging_email(submission)
      @submission = submission
      destination_email = "fstpage@princeton.edu"
      cc_email = [ "wange@princeton.edu", @submission.email ]
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           subject: I18n.t('requests.paging.email_subject'))
    end

    def annexa_email(submission)
      @submission = submission
    end

    def annexb_email(submission)
      @submission = submission
    end

    def on_order_email(submission)
      @submission = submission
    end

    def in_process_email(submission)
      @submission = submission
    end

    def recap_confirmation_email(submission)
      @submission = submission
    end

    def recall_confirmation(submission)
      @submission = submission
    end
  end
end