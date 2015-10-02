module DemoData

  class BasicFeeGenerator

    def initialize(claim)
      @claim       = claim
      @fee_types   = FeeType.basic
      @codes_added = []
    end

    def generate!
      add_baf
      add_daily_attendances
      add_pcm if @claim.case_type.allow_pcmh_fee_type?
      rand(0..3).times { add_fee }
    end

    private

    def add_baf

      @claim.fees.find_by(code: 'BAF') #(, fee_type_by_code('BAF'), 1, 250)
      @codes_added << 'BAF'
    end


    def add_daily_attendances
      add_daf if @claim.actual_trial_length > 2
      add_dah if @claim.actual_trial_length > 40
      add_daj if @claim.actual_trial_length > 50
    end

    def add_daf
      quantity = @claim.case_type.requires_trial_dates? ? @claim.actual_trial_length - 2 : 1
      amount   = @claim.case_type.requires_trial_dates? ? 250 * @claim.actual_trial_length - 2 : 250
      fee      = create_fee(@claim, fee_type_by_code('DAF'), quantity, amount)
      @codes_added << 'DAF'
    end

    def add_dah
      return unless @claim.case_type.requires_trial_dates?
      fee = create_fee(@claim, fee_type_by_code('DAH'), @claim.actual_trial_length - 40, amount: 250 * @claim.actual_trial_length - 40)
      @codes_added << 'DAH'
    end

    def add_daj
      return unless @claim.case_type.requires_trial_dates?
      fee = create_fee(@claim, fee_type_by_code('DAJ'), @claim.actual_trial_length - 50, amount: 250 * @claim.actual_trial_length - 50)
      @codes_added << 'DAJ'
    end
 
    def add_pcm
      qty = rand(0..3)
      fee = create_fee(@claim, fee_type_by_code('PCM'), qty, amount: 125)
      @codes_added << 'PCM'
    end

    def add_fee
      fee_type = @fee_types.sample
      while @codes_added.include?(fee_type.code)
        fee_type = @fee_types.sample
      end
      create_fee( @claim, fee_type, rand(0..10), rand(100..900) )
      @codes_added << fee_type.code
    end

    def fee_type_by_code(code)
      fee_type = FeeType.find_by(code: code)
      raise RuntimeError.new "Unable to find Fee Type with code #{code}" if fee_type.nil?
      fee_type
    end

    def create_fee(claim, fee_type, quantity, amount)
      Fee.create(claim: claim, fee_type: fee_type, quantity: quantity, amount: amount)
    end

  end

end



