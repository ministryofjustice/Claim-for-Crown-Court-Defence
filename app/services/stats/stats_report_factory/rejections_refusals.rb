module Stats
  module StatsReportFactory
    class RejectionsRefusals < Base
      def generator
        ReportGenerator.new('rejections_refusals', @options)
      end
    end
  end
end
