module Stats
  module StatsReportFactory
    class ProvisionalAssessment < Base
      def generator
        ReportGenerator.new('provisional_assessment', @options)
      end
    end
  end
end
