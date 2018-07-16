class ProvisionalAssessmentReportGenerationJob < ApplicationJob
  queue_as :provisional_assessment_reports

  def perform(*_args)
    Stats::ProvisionalAssessmentReportPersister.call
  end
end
