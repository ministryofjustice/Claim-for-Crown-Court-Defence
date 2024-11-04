module SurveyMonkeySender
  class Feedback < Base
    private

    def page_name = :feedback

    def payload
      {
        tasks: @answers.task,
        ratings: @answers.rating,
        comments: @answers.comment,
        reasons: reasons(@answers.reason, @answers.other_reason)
      }.compact_blank
    end

    def reasons(reason, other_reason)
      return if reason.blank?

      reason + [{ other: other_reason }]
    end
  end
end
