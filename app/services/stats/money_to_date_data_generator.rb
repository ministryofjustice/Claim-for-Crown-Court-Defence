module Stats
  class MoneyToDateDataGenerator
    def run
      stat = Statistic.where(report_name: 'money_to_date').order('date desc').first
      @data = {
        'item' => [
          {
            'value' => stat.value_1,
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
