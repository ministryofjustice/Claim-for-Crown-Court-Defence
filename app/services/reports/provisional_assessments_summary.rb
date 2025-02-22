module Reports
  class ProvisionalAssessmentsSummary < ProvisionalAssessmentsNew
    COLUMNS = %w[
      supplier_name
      total
      assessed
      disallowed
    ].freeze

    def extended_fields(claim) = []
  end
end