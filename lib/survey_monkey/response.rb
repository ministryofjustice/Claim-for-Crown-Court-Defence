require 'survey_monkey/answers'

module SurveyMonkey
  class Response
    def initialize
      @pages = []
    end

    def submit
      SurveyMonkey.configuration.connection.post(
        "collectors/#{SurveyMonkey.configuration.collector_id}/responses",
        {
          ip_address: '127.0.0.1',
          pages: @pages.map(&:to_h)
        }.to_json,
        content_type: 'application/json'
      )
    end

    def add_page(page, **responses)
      @pages << SurveyMonkey.page_by_name(page).answers(**responses)
    end
  end
end
