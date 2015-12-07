module Requests
  module ApplicationHelper
    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end

    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end
  end
end
