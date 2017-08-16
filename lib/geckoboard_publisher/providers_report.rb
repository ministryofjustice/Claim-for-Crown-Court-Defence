module GeckoboardPublisher
  class ProvidersReport < Report
    def initialize(start_date = Date.yesterday, end_date = nil)
      super
      @start_date = start_date
      @end_date = end_date.present? ? end_date : start_date
    end

    def fields
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:firms_added, name: 'Firms added'),
        Geckoboard::NumberField.new(:chambers_added, name: 'Chambers added'),
        Geckoboard::NumberField.new(:total_added, name: 'Total created'),
        Geckoboard::NumberField.new(:overall_count, name: 'Overall provider count')
      ]
    end

    def items
      items = []
      (@start_date..@end_date).each do |date|
        data = Provider.unscoped.where(created_at: date.beginning_of_day..date.end_of_day).group(:provider_type).count
        record = { date: 0, firms_added: 0, chambers_added: 0, total_added: 0, overall_count: 0 }
        record[:date] = date.to_date.iso8601
        if data.present?
          record[:firms_added] = data['firm'] unless data['firm'].nil?
          record[:chambers_added] = data['chamber'] unless data['chamber'].nil?
          record[:total_added] = record[:firms_added] + record[:chambers_added]
        end
        record[:overall_count] = Provider.where('created_at < ?', date.end_of_day).count
        items << record
      end
      items
    end

    def unique_by
      [:date]
    end
  end
end
