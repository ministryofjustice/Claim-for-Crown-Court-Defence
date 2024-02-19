class SurveyMonkeySender
  def self.call(feedback)
    new(feedback).call
  end

  def initialize(feedback)
    @feedback = feedback
    response.add_page(:feedback, **payload)
  end

  def call
    return_hash = {}
    resp = response.submit

    return_hash[:success] = resp[:success]

    return_hash[:response_message] = if resp[:success]
                                'Feedback submitted'
                              else
                                "Unable to submit feedback [#{resp[:error_code]}]"
                              end

    return_hash
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
    }.compact_blank
  end

  def reasons(reason, other_reason)
    return if reason.blank?

    reason + [{ other: other_reason }]
  end
end
