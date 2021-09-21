require 'survey_monkey/answers'

module SurveyMonkey
  class Response
    def initialize
      @pages = []
    end

    def submit
      survey_response = { pages: @pages.map(&:to_h) }
      SurveyMonkey.log(:info, "Sending response. #{survey_response.inspect}")

      response = SurveyMonkey.connection.post(
        "collectors/#{SurveyMonkey.collector_id}/responses",
        survey_response.to_json,
        content_type: 'application/json'
      )

      parse_response(response)
    end

    def add_page(page, **responses)
      @pages << SurveyMonkey.page_by_name(page).answers(**responses)
    end

    private

    def parse_response(response)
      body = JSON.parse(response.body)
      if response.success?
        SurveyMonkey.log(:info, "Response submitted. #{body['analyze_url']}")
        { id: JSON.parse(response.body)['id']&.to_i, success: true }
      else
        SurveyMonkey.log(:error, "Failed to submit response: #{body}")
        { success: false, error_code: body['error']['id'].to_i }
      end
    end
  end
end
