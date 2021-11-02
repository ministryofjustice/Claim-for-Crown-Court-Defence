module Stats
  module StatsReportFactory
    class LgfsManagementInformationV2 < Base
      def generator
        Stats::ManagementInformation::DailyReportGenerator.new(**@options.merge(scheme: :lgfs))
      end
    end
  end
end
