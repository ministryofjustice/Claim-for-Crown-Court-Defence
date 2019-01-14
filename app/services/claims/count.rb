module Claims
  class Count
    class << self
      def quarter(date)
        new(date, :quarter).call
      end

      def month(date)
        new(date, :month).call
      end

      def week(date)
        new(date, :week).call
      end
    end

    def initialize(date, period)
      date = Date.parse(date.to_s || Date.today.to_s)
      @start = date.send("beginning_of_#{period}").beginning_of_day.to_s(:db)
      @end = date.send("end_of_#{period}").end_of_day.to_s(:db)
    end

    def call
      Claim::BaseClaim.where(original_submission_date: @start..@end).count
    end
  end
end
