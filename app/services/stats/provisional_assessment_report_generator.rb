module Stats
  class ProvisionalAssessmentReportGenerator
    DEFAULT_FORMAT = 'csv'.freeze

    def self.call(options = {})
      new(options).call
    end

    def initialize(options)
      @format = options.fetch(:format, DEFAULT_FORMAT)
    end

    def call
      data = Reports::ProvisionalAssessments.call
      output = Stats::CsvExporter.call(data, headers: Reports::ProvisionalAssessments::COLUMNS)
      Stats::Result.new(output, format)
    end

    private

    attr_reader :format
  end
end
