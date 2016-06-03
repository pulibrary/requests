module Requests
  class RequestMailer < ApplicationMailer
    def paging_email(submission)
      @submission = submission
      destination_email = "fstpage@princeton.edu"
      cc_email = "wange@princeton.edu"
      @url  = 'http://example.com/login'
      mail(to: destination_email, 
           cc: cc_email,
           subject: I18n.t('requests.paging.email_subject'))
    end
  end
end