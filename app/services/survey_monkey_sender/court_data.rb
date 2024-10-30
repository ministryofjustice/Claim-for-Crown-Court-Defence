module SurveyMonkeySender
  class CourtData < Base
    private

    def page_name = :court_data

    def payload
      {
        case_number: @answers.case_number,
        claim_id: @answers.claim_id,
        comments: @answers.comments
      }.compact_blank
    end
  end
end
