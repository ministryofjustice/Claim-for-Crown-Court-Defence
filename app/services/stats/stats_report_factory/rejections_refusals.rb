module Stats
  module StatsReportFactory
    class RejectionsRefusals < Base
      def generator
        ReportGenerator.new(**@options.merge(report_klass: Reports::RejectionsRefusals))
      end
    end
  end
end
