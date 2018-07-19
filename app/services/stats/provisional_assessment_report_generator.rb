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
      Stats::CsvExporter.call(data, headers: Reports::ProvisionalAssessments::COLUMNS)
    end

    private

    attr_reader :format
  end
end
