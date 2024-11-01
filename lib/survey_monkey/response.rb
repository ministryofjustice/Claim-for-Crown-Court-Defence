module SurveyMonkey
  class Response
    delegate :connection, :page_by_name, :log, to: :SurveyMonkey, private: true

    def initialize
      @pages = []
      @collector = nil
    end

    def submit
      survey_response = { pages: @pages.map(&:to_h) }
      log(:info, "Sending response. #{survey_response.inspect}")

      response = connection.post(
        "collectors/#{@collector.id}/responses",
        survey_response.to_json,
        content_type: 'application/json'
      )

      parse(response)
    end

    def add_page(page_id, **)
      page = page_by_name(page_id)
      update_collector(page)
      @pages << page.answers(**)
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

    def update_collector(page)
      if @collector.nil?
        @collector = page.collector
      else
        raise MismatchedCollectors unless @collector == page.collector
      end
    end
  end
end
