module Stats
  class SimpleReportGenerator
    def self.call(...)
      new(...).call
    end

    def call
      data = report_klass.call
      output = Stats::CsvExporter.call(data, headers: report_klass::COLUMNS)
      Stats::Result.new(output, @format)
    end

    def initialize(**kwargs)
      @report = kwargs[:report_type]
      @format = kwargs.fetch(:format, 'csv')
    end

    private

    def report_klass
      @report_klass ||= {
        provisional_assessment: Reports::ProvisionalAssessments,
        rejections_refusals: Reports::RejectionsRefusals,
        submitted_claims: Reports::SubmittedClaims,
        provisional_assessment_new: Reports::ProvisionalAssessmentsNew,
        provisional_assessment_new: Reports::ProvisionalAssessmentsSummary,
      }[@report.to_sym]
    end
  end
end
