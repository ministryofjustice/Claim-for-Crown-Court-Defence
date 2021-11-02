module Stats
  module StatsReportFactory
    class ManagementInformationV2 < Base
      def generator
        Stats::ManagementInformation::DailyReportGenerator.new(**@options)
      end
    end
  end
end
