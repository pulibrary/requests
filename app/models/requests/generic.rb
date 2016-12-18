module Requests
  class Generic

    def initialize(submission)
      @submission = submission
      @sent = [] #array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] #array of hashes with bibid and item_id and error message
      handle
    end

    def handle
        #something will go here eventually
    end

    def submitted
      @sent
    end

    def errors
      @errors
    end

  end
end
