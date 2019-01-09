module Stats
  class QuarterlyVolumeGenerator
    DEFAULT_FORMAT = 'csv'.freeze

    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @format = options.fetch(:format, DEFAULT_FORMAT)
      @options = options.except(:format)
      @gbp_total = 0.0
    end

    def call
      output = generate_new_report
      Stats::Result.new(output.as_json.to_s, format)
    end

    private

    attr_reader :format

    def generate_new_report
      result = base_hash
      3.times do |int|
        result.merge!(calculate_gbp_for_(int))
      end
      totals = {
        total_quarter_cost: @gbp_total.to_f.round(2),
        claim_count: count_digital_claims,
        cost_per_transaction_quarter: (@gbp_total / count_digital_claims).to_f.round(2)
      }
      result.merge!(totals)
      result
    end

    def base_hash
      {
        total_quarter_cost: nil,
        claim_count: nil,
        cost_per_transaction_quarter: nil,
        month_one: { date: nil, usd_value: nil, gbp_value: nil },
        month_two: { date: nil, usd_value: nil, gbp_value: nil },
        month_three: { date: nil, usd_value: nil, gbp_value: nil }
      }
    end

    def calculate_gbp_for_(month_offset)
      date = (start_date + month_offset.months).end_of_month
      usd_value = @options[:"month_#{month_offset + 1}"]
      gbp_value = Conversion::Currency.call(date, usd_value)
      @gbp_total += gbp_value
      { "month_#{number_to_text(month_offset + 1)}": { date: date, usd_value: usd_value, gbp_value: gbp_value } }
    end

    def number_to_text(value)
      { '1' => 'one', '2' => 'two', '3' => 'three' }[value.to_s]
    end

    def start_date
      @start_date ||= Date.parse(@options[:quarter_start])
    end

    def count_digital_claims
      first = @start_date.beginning_of_day.to_s(:db)
      last = @start_date.end_of_quarter.end_of_day.to_s(:db)
      @count_digital_claims ||= Claim::BaseClaim.where(original_submission_date: first..last).count
    end
  end
end
