module Stats
  module StatsReportFactory
    class SubmittedClaims < Base
      def generator
        ReportGenerator.new('submitted_claims', @options)
      end
    end
  end
end
