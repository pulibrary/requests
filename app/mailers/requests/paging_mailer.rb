module Requests
  class PagingMailer < ApplicationMailer
    def paging_email(user)
      @user = user
      @url  = 'http://example.com/login'
      mail(to: @user.email, subject: 'Paging Request')
    end
  end
end