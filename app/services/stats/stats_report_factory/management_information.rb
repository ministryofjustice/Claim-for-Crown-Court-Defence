module Stats
  module StatsReportFactory
    class ManagementInformation < Base
      def generator
        ManagementInformationGenerator.new(**@options)
      end
    end
  end
end
