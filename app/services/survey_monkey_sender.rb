class SurveyMonkeySender
  def self.send_response(feedback)
    new(feedback).send_response
  end

  def initialize(feedback)
    @survey_response = SurveyMonkey::Response.new
    @survey_response.add_page(:feedback, **payload(feedback))
  end

  def send_response
    @survey_response.submit
  end

  private

  def payload(feedback)
    {
      tasks: feedback.task,
      ratings: feedback.rating,
      comments: feedback.comment,
      reasons: reasons(feedback.reason, feedback.other_reason)
    }.delete_if { |_, value| value.blank? }
  end

  def reasons(reason, other_reason)
    return if reason.blank?

    reason + [{ other: other_reason }]
  end
end
