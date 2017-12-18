# CCR requires the total number of daily attendances.
# This can be derived from CCCD data as follows:
# The number of attendances claimed is equal to
# the total of quantities claimed for the 3 DAF/H/J
# basic fees + 2 (included in the basic fee). If there
# are none claimed then the attendance can be said to be
# the least of actual trial length or 2 (included in the
# basic fee) - CCR will ignore this value
# if it is not approrpiate e.g. for guilty pleas
module CCR
  class DailyAttendanceAdapter
    attr_reader :claim

    def initialize(claim)
      @claim = claim
    end

    class << self
      def attendances_for(claim)
        adapter = new(claim)
        adapter.attendances
      end
    end

    def attendances
      if daily_attendance_uplifts?
        daily_attendance_uplifts + DAILY_ATTENDANCES_IN_BASIC
      else
        [trial_length, DAILY_ATTENDANCES_IN_BASIC].compact.min
      end
    end

    private

    # The first 2 daily attendances are included in the Basic Fee (BABAF)
    DAILY_ATTENDANCES_IN_BASIC = 2

    def trial_length
      claim&.case_type&.requires_retrial_dates? ? claim&.retrial_actual_length : claim&.actual_trial_length
    end

    def daily_attendance_fee_types
      ::Fee::BasicFeeType.where(unique_code: %w[BADAF BADAH BADAJ])
    end

    def daily_attendance_uplifts
      @attendance_uplifts ||= claim.fees.where(fee_type_id: daily_attendance_fee_types).sum(:quantity).to_i
    end

    def daily_attendance_uplifts?
      daily_attendance_uplifts.positive?
    end
  end
end
