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
          value: reporter.rejected[:percentage],
          text: 'Rejected'
        },
        {
          value: reporter.authorised_in_part[:percentage],
          text: 'Part authorised'
        },
        {
          value: reporter.authorised_in_full[:percentage],
          text: 'Authorised'
        }
      ]
    end
  end
end
