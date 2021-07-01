module Stats
  module ReportGenerator
    class SubmittedClaims < Base
      def reporter
        Reports::SubmittedClaims
      end
    end
  end
end
