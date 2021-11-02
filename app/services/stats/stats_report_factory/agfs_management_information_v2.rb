module Stats
  module StatsReportFactory
    class AgfsManagementInformationV2 < Base
      def generator
        Stats::ManagementInformation::DailyReportGenerator.new(**@options.merge(scheme: :agfs))
      end
    end
  end
end
