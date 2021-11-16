module Requests::Submissions
  class Generic
    attr_reader :service_type, :success_message

    def initialize(submission, service_type: 'generic')
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
      @service_type = service_type
      @success_message = I18n.t("requests.submit.#{service_type}_success", default: I18n.t('requests.submit.success'))
    end

    def handle
      # something will go here eventually
    end

    def submitted
      @sent
    end

    attr_reader :errors
  end
end
