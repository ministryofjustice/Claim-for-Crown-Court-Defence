class SurveyMonkeySender
  def self.call(...)
    new(...).call
  end

  def initialize(feedback)
    @feedback = feedback
    response.add_page(:feedback, **payload)
  end

  def call
    {
      success: success?,
      response_message: message
    }
  end

  private

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
    return 'Feedback submitted' if success?

    "Unable to submit feedback [#{error_code}]"
  end

  def error_code
    @error_code ||= submission_response[:error_code]
  end

  def payload
    {
      tasks: @feedback.task,
      ratings: @feedback.rating,
      comments: @feedback.comment,
      reasons: reasons(@feedback.reason, @feedback.other_reason)
    }.compact_blank
  end

  def reasons(reason, other_reason)
    return if reason.blank?

    reason + [{ other: other_reason }]
  end
end
