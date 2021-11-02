module Stats
  module StatsReportFactory
    class LgfsManagementInformation < Base
      def generator
        ManagementInformationGenerator.new(**@options.merge(scheme: :lgfs))
      end
    end
  end
end
