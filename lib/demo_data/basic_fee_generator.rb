module DemoData

  class BasicFeeGenerator

    def initialize(claim)
      @claim       = claim
      @fee_types   = Fee::BasicFeeType.all
      @codes_added = []
    end

    def generate!
      add_baf
      add_daily_attendances
      add_pcm if @claim.case_type.allow_pcmh_fee_type?
      add_ppe if rand(2)==1
      add_npw if rand(2)==1
      rand(0..3).times { add_fee }
    end

    private


    def update_basic_fee(basic_fee_code, attributes={})
      fee = @claim.basic_fees.find_by(fee_type_id: basic_fee_type_by_code(basic_fee_code))
      fee.update(attributes)
      @codes_added << basic_fee_code
    end

    def add_baf
      update_basic_fee('BAF', quantity: 1, rate: 250)
    end

    def add_daily_attendances
      if @claim.case_type.requires_retrial_dates?
        @trial_length = @claim.retrial_actual_length
      elsif @claim.case_type.requires_trial_dates?
        @trial_length = @claim.actual_trial_length
      else
        return
      end

      add_daf if @trial_length > 2
      add_dah if @trial_length > 40
      add_daj if @trial_length > 50

    end

    def add_daily_attendance(type_code)
        options = { daf: { modifier: -2, max: 40 },
          dah: { modifier: -40, max: 50 },
          daj: { modifier: -50, max: 60 }
        }

        trial_length_field = @claim.case_type.requires_retrial_dates? ? :retrial_actual_length : :actual_trial_length
        quantity = [@claim.try(trial_length_field),options[type_code][:max]].min + options[type_code][:modifier]
        rate   = 10 * @claim.try(trial_length_field) + options[type_code][:modifier]
        update_basic_fee(type_code.to_s.upcase, quantity: quantity, rate: rate.round(2))
    end

    def add_daf
      add_daily_attendance(:daf)
    end

    def add_dah
      add_daily_attendance(:dah)
    end

    def add_daj
      add_daily_attendance(:daj)
    end

    def add_pcm
      update_basic_fee('PCM', quantity: rand(1..3), rate: 125)
    end

    def add_npw
      update_basic_fee('NPW',quantity: 777, amount: 200)
    end

    def add_ppe
      update_basic_fee('PPE',quantity: 800, amount: 200)
    end

    def add_fee
      fee_type = @fee_types.where(calculated: true).sample
      while @codes_added.include?(fee_type.code) || ['BAF','DAF','DAH','DAJ','PCM'].include?(fee_type.code)
        fee_type = @fee_types.where(calculated: true).sample
      end
      update_basic_fee(fee_type.code, quantity: rand(1..10), rate: rand(100..900) )
    end

    def basic_fee_type_by_code(code)
      fee_type = Fee::BasicFeeType.find_by(code: code)
      raise RuntimeError.new "Unable to find Fee Type with code #{code}" if fee_type.nil?
      fee_type
    end

  end

end



