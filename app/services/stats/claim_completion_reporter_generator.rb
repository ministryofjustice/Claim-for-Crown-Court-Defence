module Stats
  class ClaimCompletionReporterGenerator
    attr_reader :reporter

    def initialize(reporter)
      @reporter = reporter
    end

    def to_hash
      { item: item, min: min, max: max }
    end

    private

    def item
      reporter.completion_rate.round
    end

    def min
      { value: 0 }
    end

    def max
      { value: 100 }
    end
  end
end
