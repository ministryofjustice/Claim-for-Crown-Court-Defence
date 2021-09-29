class SurveyMonkeySender
  def self.call(feedback)
    new(feedback).call
  end

  def initialize(feedback)
    @feedback = feedback
    response.add_page(:feedback, **payload)
  end

  def call
    response.submit
  end

  private

  def response
    @response ||= SurveyMonkey::Response.new
  end

  def payload
    {
      tasks: @feedback.task,
      ratings: @feedback.rating,
      comments: @feedback.comment,
      reasons: reasons(@feedback.reason, @feedback.other_reason)
    }.delete_if { |_, value| value.blank? }
  end

  def reasons(reason, other_reason)
    return if reason.blank?

    reason + [{ other: other_reason }]
  end
end
