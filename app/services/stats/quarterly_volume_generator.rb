module Stats
  class QuarterlyVolumeGenerator
    DEFAULT_FORMAT = 'json'.freeze

    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @format = options.fetch(:format, DEFAULT_FORMAT)
    end

    def call
      output = generate_new_report
      Stats::Result.new(output, format)
    end

    private

    attr_reader :format

    def generate_new_report
      {
        _id: 'xxxxx',
        _timestamp: '2017-04-01T00:00:00+00:00',
        cost_per_transaction_quarter: '0.5',
        end_at: '2017-07-01T00:00:00+00:00',
        period: 'quarter',
        service: 'Crown Court Defence',
        start_at: '2017-04-01T00:00:00+00:00',
        total_cost_quarter: '1276.9',
        transactions_per_quarter: '0.18'
      }
    end
  end
end
