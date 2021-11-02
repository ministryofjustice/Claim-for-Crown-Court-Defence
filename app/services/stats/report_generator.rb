module Stats
  class ReportGenerator
    def self.call(*args)
      new(*args).call
    end

    def call
      data = @report_klass.call
      output = Stats::CsvExporter.call(data, headers: @report_klass::COLUMNS)
      Stats::Result.new(output, @format)
    end

    def initialize(report_klass:, format: 'csv')
      @format = format
      @report_klass = report_klass
    end
  end
end
