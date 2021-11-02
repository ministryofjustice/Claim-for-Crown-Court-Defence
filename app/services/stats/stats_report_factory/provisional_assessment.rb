module Stats
  module StatsReportFactory
    class ProvisionalAssessment < Base
      def generator
        ReportGenerator.new(**@options.merge(report_klass: Reports::ProvisionalAssessments))
      end
    end
  end
end
