module Requests
  class Recap

    include Requests::Gfa
    
    def initialize(submission)
      @submission = submission
      @sent = nil
    end

    def handle
      @submission.items.each do |item|
        params = param_mapping(@submission.bib, @submission.user, item)
      end
      @sent = true
    end

    def submitted?
      @sent
    end

  end
end