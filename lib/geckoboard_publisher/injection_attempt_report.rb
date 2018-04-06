module GeckoboardPublisher
  class InjectionAttemptReport < Report
    def initialize(start_date = Date.yesterday, end_date = nil)
      super
      @start_date = start_date
      @end_date = end_date.present? ? end_date : start_date
    end

    def fields
      [
        Geckoboard::NumberField.new(:succeeded, name: 'Succeeded'),
        Geckoboard::NumberField.new(:failed, name: 'Failed')
      ]
    end

    def items
      sets = InjectionAttempt.group(:succeeded).count
      record = { succeeded: sets[true], failed: sets[false] }
      [record]
    end
  end
end
