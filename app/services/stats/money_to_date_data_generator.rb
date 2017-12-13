module Stats
  class MoneyToDateDataGenerator
    def run
      stat = Statistic.where(report_name: 'money_claimed_per_month').sum(:value_1)
      @data = {
        'item' => [
          {
            'value' => stat,
            'prefix' => '£'
          }
        ]
      }
    end

    def to_json
      @data.to_json
    end
  end
end
