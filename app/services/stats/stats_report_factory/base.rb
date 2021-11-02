module Stats
  module StatsReportFactory
    class Base
      def self.generator(options)
        new(options).generator
      end

      def initialize(options = {})
        @options = options
      end
    end
  end
end
