module Stats
  module StatsReportFactory
    class AgfsManagementInformation < Base
      def generator
        ManagementInformationGenerator.new(**@options.merge(scheme: :agfs))
      end
    end
  end
end
