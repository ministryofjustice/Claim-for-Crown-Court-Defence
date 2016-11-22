module Stats
  class ClaimsReporterGenerator
    attr_reader :reporter

    def initialize(reporter)
      @reporter = reporter
    end

    def to_hash
      {item: item}
    end


    private

    def item
      [
        {
          value: reporter.rejected,
          text: 'Rejected'
        },
        {
          value: reporter.authorised_in_part,
          text: 'Part authorised'
        },
        {
          value: reporter.authorised_in_full,
          text: 'Authorised'
        }
      ]
    end
  end
end
