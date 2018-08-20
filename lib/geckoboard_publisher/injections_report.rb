module GeckoboardPublisher
  class InjectionsReport < Report
    def initialize(start_date = Date.yesterday, end_date = nil)
      super
      @start_date = start_date
      @end_date = end_date.present? ? end_date : start_date
    end

    def fields
      [Geckoboard::DateField.new(:date, name: 'Date')] + ccr_fields + cclf_fields + totals_fields
    end

    def items
      items = []
      (@start_date..@end_date).each do |date|
        items << InjectionRecord.new(date).to_h
      end
      items
    end

    def unique_by
      [:date]
    end

    private

    def ccr_fields
      [
        Geckoboard::NumberField.new(:total_ccr_succeeded, name: 'Total CCR'),
        Geckoboard::NumberField.new(:total_ccr, name: 'Total number of CCR injections'),
        Geckoboard::PercentageField.new(:percentage_ccr_succeeded,
                                        name: 'Percentage of successful CCR injections', optional: true)
      ]
    end

    def cclf_fields
      [
        Geckoboard::NumberField.new(:total_cclf_succeeded, name: 'Total CCLF succeeded'),
        Geckoboard::NumberField.new(:total_cclf, name: 'Total number of CCLF injections'),
        Geckoboard::PercentageField.new(:percentage_cclf_succeeded,
                                        name: 'Percentage of successful CCLF injections', optional: true)
      ]
    end

    def totals_fields
      [
        Geckoboard::NumberField.new(:total_succeeded, name: 'Total succeeded'),
        Geckoboard::NumberField.new(:total, name: 'Total number of injections')
      ]
    end
  end
end
