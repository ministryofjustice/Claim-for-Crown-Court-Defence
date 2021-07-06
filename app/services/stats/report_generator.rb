module Stats
  class ReportGenerator
    def self.call(*args)
      new(*args).call
    end

    def call
      data = report_klass.call
      output = Stats::CsvExporter.call(data, headers: report_klass::COLUMNS)
      Stats::Result.new(output, @format)
    end

    def initialize(report, format: 'csv')
      @report = report
      @format = format
    end

    private

    def report_klass
      @report_klass ||= {
        provisional_assessment: Reports::ProvisionalAssessments,
        rejections_refusals: Reports::RejectionsRefusals,
        submitted_claims: Reports::SubmittedClaims
      }[@report.to_sym]
    end
  end
end
