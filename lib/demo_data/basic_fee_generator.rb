module DemoData

  class BasicFeeGenerator

    def initialize(claim)
      @claim       = claim
      @fees        = FeeType.basic
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
      fee = FactoryGirl.create :fee, :baf_fee, claim: @claim, quantity: 1, amount: 250
      @codes_added << 'baf'
    end


    def add_daily_attendances
      add_daf if @claim.actual_trial_length > 2
      add_dah if @claim.actual_trial_length > 40
      add_daj if @claim.actual_trial_length > 50
    end

    def add_daf
      fee = FactoryGirl.create :fee, :daf_fee, claim: @claim, quantity: @claim.actual_trial_length - 2, amount: 250 * @claim.actual_trial_length - 2
      @codes_added << 'daf'
    end

    def add_dah
      fee = FactoryGirl.create :fee, :dah_fee, claim: @claim, quantity: @claim.actual_trial_length - 40, amount: 250 * @claim.actual_trial_length - 40
      @codes_added << 'dah'
    end

    def add_daj
      fee = FactoryGirl.create :fee, :daj_fee, claim: @claim, quantity: @claim.actual_trial_length - 50, amount: 250 * @claim.actual_trial_length - 50
      @codes_added << 'daj'
    end
 
    def add_pcm
      qty = rand(0..3)
      fee = FactoryGirl.create :fee, :pcm_fee, claim: @claim, quantity: qty , amount: 125
      @codes_added << 'pcm'
    end

    def add_fee
      fee_type = @fees.sample
      while @codes_added.include?(fee_type.code)
        fee_type = @fees.sample
      end
      fee = FactoryGirl.create :fee, fee_type: fee_type, claim: @claim, quantity: rand(0..10), amount: rand(100..900)
      @codes_added << fee_type.code
    end
  
  end
end



