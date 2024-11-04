module SurveyMonkeySender
  class Base
    def self.call(...)
      new(...).call
    end

    def initialize(answers)
      @answers = answers
      response.add_page(page_name, **payload)
    end

    def call
      {
        success: success?,
        response_message: message
      }
    end

    private

    def success_message = 'Feedback submitted'
    def failure_message = 'Unable to submit feedback'

    def response
      @response ||= SurveyMonkey::Response.new
    end

    def submission_response
      @submission_response ||= response.submit
    end

    def success?
      @success ||= submission_response[:success]
    end

    def message
      return success_message if success?

      "#{failure_message} [#{error_code}]"
    end

    def error_code
      @error_code ||= submission_response[:error_code]
    end
  end
end
