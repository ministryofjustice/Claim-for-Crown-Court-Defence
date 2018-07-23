# CCR requires the total number of daily attendances.
# This can be derived from CCCD data as follows:
#
# 1. For AGFS scheme 9 claims:
#
# The number of attendances claimed is equal to
# the total of quantities claimed for the 3 DAF/H/J
# basic fees + 2 (included in the basic fee). If there
# are none claimed then the attendance can be said to be
# the least of actual trial length or 2 (included in the
# basic fee) - CCR will ignore this value if it is not
# approrpiate e.g. for guilty pleas
#
# 2. For AGFS scheme 10 claims:
#
# The number of attendances claimed is equal to
# the quantities claimed for the single DAT
# basic fee + 1 (included in the basic fee). If there
# are none claimed then the attendance can be said to be
# the least of actual trial length or 1 (included in the
# basic fee) - CCR will ignore this value if it is not
# approrpiate e.g. for guilty pleas
#
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
        daily_attendance_uplifts + daily_attendances_in_basic
      else
        [trial_length, daily_attendances_in_basic].compact.min
      end
    end

    private

    def daily_attendances_in_basic
      claim.agfs_reform? ? 1 : 2
    end

    def trial_length
      claim&.trial_length
    end

    def eligible_fee_type_unique_codes
      claim.agfs_reform? ? 'BADAT' : %w[BADAF BADAH BADAJ]
    end

    def daily_attendance_fee_types
      ::Fee::BasicFeeType.where(unique_code: eligible_fee_type_unique_codes)
    end

    def daily_attendance_uplifts
      @attendance_uplifts ||= claim.fees.where(fee_type_id: daily_attendance_fee_types).sum(:quantity).to_i
    end

    def daily_attendance_uplifts?
      daily_attendance_uplifts.positive?
    end
  end
end
