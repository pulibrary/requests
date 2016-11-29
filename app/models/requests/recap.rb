module Requests
  class Recap

    include Requests::Gfa
    
    def initialize(submission)
      @submission = submission
      @sent = nil
      @errors = nil
      handle
    end

    def handle
      @submission.items.each do |item|
        params = param_mapping(@submission.bib, @submission.user, item)
      end
      ##TODO invoke methods from the gfa concern that execute request
      @sent = true
    end

    def submitted?
      @sent
    end

  end
end