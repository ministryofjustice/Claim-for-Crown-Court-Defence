module GeckoboardPublisher
  class TravelAutomationReport < Report
    def initialize(start_date = Date.yesterday, end_date = nil)
      super
      @start_date = start_date
      @end_date = end_date.present? ? end_date : start_date
    end

    def push!
      return unless widget_key.present?
      url = "https://push.geckoboard.com/v1/send/#{widget_key}"
      RestClient.post(url, payload(items.last).to_json, content_type: :json)
    end

    def fields
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:total_calculated, name: 'Total calculated'),
        Geckoboard::NumberField.new(:accepted, name: 'Distances accepted'),
        Geckoboard::NumberField.new(:increased, name: 'Distances increased'),
        Geckoboard::NumberField.new(:reduced, name: 'Distances reduced'),
        Geckoboard::PercentageField.new(:percent_accepted, name: 'Percentage of distances accepted'),
        Geckoboard::PercentageField.new(:percent_increased, name: 'Percentage of distances increased'),
        Geckoboard::PercentageField.new(:percent_reduced, name: 'Percentage of distances reduced'),
        Geckoboard::MoneyField.new(:cost_increased, currency_code: 'GBP', name: 'Cost of increased claims'),
        Geckoboard::MoneyField.new(:cost_reduction, currency_code: 'GBP', name: 'Cost of reduced claims')
      ]
    end

    def items
      return @items if @items.present?
      items = []
      (@start_date..@end_date).each do |date|
        start_at = date.beginning_of_day.to_s(:db)
        end_at = date.end_of_day.to_s(:db)

        expenses = Expense
                   .joins(:claim)
                   .where(claims: { original_submission_date: start_at..end_at })
                   .where('calculated_distance IS NOT NULL')

        record = { date: date.to_date.iso8601 }
        fields.from(1).map(&:id).each { |field| record[field.to_sym] = 0 }

        if expenses.present?
          record[:total_calculated] = expenses.count
          record[:accepted] = expenses.where('calculated_distance = distance').count
          record[:increased] = expenses.where('calculated_distance < distance').count
          record[:reduced] = expenses.where('calculated_distance > distance').count
          record[:percent_accepted] = (record[:accepted].to_f / record[:total_calculated].to_f).to_f.round(2)
          record[:percent_increased] = (record[:increased].to_f / record[:total_calculated].to_f).to_f.round(2)
          record[:percent_reduced] = (record[:reduced].to_f / record[:total_calculated].to_f).to_f.round(2)
          record[:cost_increased] = calculate_cost(expenses.where('calculated_distance < distance'), :increase)
          record[:cost_reduction] = calculate_cost(expenses.where('calculated_distance > distance'), :reduction)
        end
        items << record
      end
      @items = items
      @items
    end

    def unique_by
      [:date]
    end

    private

    def calculate_cost(collection, change)
      total = 0
      collection.each do |expense|
        user_total, calculated_total = calculate_totals(expense)
        if change.eql?(:increase)
          total += (user_total - calculated_total)
        elsif change.eql?(:reduction)
          total += (calculated_total - user_total)
        end
      end
      total.to_s.tr('.', '').to_i
    end

    def calculate_totals(expense)
      user_entered_total = expense.amount + expense.vat_amount
      mileage_rate = Expense::CAR_MILEAGE_RATES[expense.mileage_rate_id].rate
      calc_amount = (expense.calculated_distance * mileage_rate)
      calc_vat = VatRate.vat_amount(calc_amount, expense.claim.vat_date, calculate: expense.claim.apply_vat?)
      calculated_total = calc_amount + calc_vat
      [user_entered_total, calculated_total]
    end

    def payload(item)
      {
        api_key: ENV['GECKOBOARD_API_KEY'],
        data:
          {
            item: [
              {
                value: item[:increased],
                text: 'increased'
              },
              {
                value: item[:reduced],
                text: 'reduced'
              },
              {
                value: item[:accepted],
                text: 'accepted'
              }
            ]
          }
      }
    end

    def widget_key
      @widget_key ||= Settings.geckoboard.widgets.travel_automation
    end
  end
end
