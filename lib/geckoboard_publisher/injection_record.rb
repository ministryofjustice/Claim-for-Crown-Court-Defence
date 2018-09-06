module GeckoboardPublisher
  class InjectionRecord
    attr_reader :date

    def initialize(date)
      @date = date.to_date
      @date_range = @date.beginning_of_day..@date.end_of_day
    end

    def to_h
      { date: date.iso8601 }
        .merge(ccr_fields)
        .merge(cclf_fields)
        .merge(totals_fields)
    end

    private

    attr_reader :date_range

    def ccr_fields
      {
        total_ccr_succeeded: total_ccr_succeeded,
        total_ccr: total_ccr,
        percentage_ccr_succeeded: percentage(total_ccr_succeeded, total_ccr)
      }
    end

    def cclf_fields
      {
        total_cclf_succeeded: total_cclf_succeeded,
        total_cclf: total_cclf,
        percentage_cclf_succeeded: percentage(total_cclf_succeeded, total_cclf)
      }
    end

    def totals_fields
      {
        total_succeeded: total_ccr_succeeded + total_cclf_succeeded,
        total: total
      }
    end

    def ccr_injections
      InjectionAttempt.joins(:claim).merge(Claim::BaseClaim.agfs)
    end

    def cclf_injections
      InjectionAttempt.joins(:claim).merge(Claim::BaseClaim.lgfs)
    end

    def total_ccr_succeeded
      @total_ccr_succeeded ||=
        ccr_injections.where(succeeded: true).where(created_at: date_range).count
    end

    def total_cclf_succeeded
      @total_cclf_succeeded ||=
        cclf_injections.where(succeeded: true).where(created_at: date_range).count
    end

    def total_ccr
      ccr_injections
        .where(created_at: date_range)
        .exclude_error('%already exist%')
        .count
    end

    def total_cclf
      cclf_injections.where(created_at: date_range).count
    end

    def total
      InjectionAttempt
        .where(created_at: date_range)
        .exclude_error('%already exist%')
        .count
    end

    def percentage(numerator, denominator)
      return 0 if denominator.zero?
      numerator / denominator.to_f
    end
  end
end
