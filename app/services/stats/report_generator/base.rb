module Stats
  module ReportGenerator
    class Base
      DEFAULT_FORMAT = 'csv'.freeze

      def self.call(options = {})
        new(options).call
      end

      def call
        data = reporter.call
        output = Stats::CsvExporter.call(data, headers: reporter::COLUMNS)
        Stats::Result.new(output, @format)
      end

      def initialize(options)
        @format = options.fetch(:format, DEFAULT_FORMAT)
      end
    end
  end
end
