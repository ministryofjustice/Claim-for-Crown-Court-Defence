module Stats
  module StatsReportFactory
    class SubmittedClaims < Base
      def generator
        ReportGenerator.new(**@options.merge(report_klass: Reports::SubmittedClaims))
      end
    end
  end
end
