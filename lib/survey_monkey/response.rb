module SurveyMonkey
  class Response
    delegate :connection, :collector_id, :page_by_name, :log, to: :SurveyMonkey, private: true

    def initialize
      @pages = []
    end

    def submit
      survey_response = { pages: @pages.map(&:to_h) }
      log(:info, "Sending response. #{survey_response.inspect}")

      response = connection.post(
        "collectors/#{collector_id}/responses",
        survey_response.to_json,
        content_type: 'application/json'
      )

      parse(response)
    end

    def add_page(page, **)
      @pages << page_by_name(page).answers(**)
    end

    private

    def parse(response)
      body = JSON.parse(response.body)
      if response.success?
        log(:info, "Response submitted. #{body['analyze_url']}")
        { id: body['id']&.to_i, success: true }
      else
        log(:error, "Failed to submit response: #{body}")
        { success: false, error_code: body['error']['id'].to_i }
      end
    end
  end
end
