module Claims
  class ValidateAllSteps
    def self.call(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
      @original_step = claim.form_step
    end

    def call
      full_submission_flow.each_with_object([]) do |stage, memo|
        claim.form_step = stage
        claim.force_validation = true
        memo << stage unless claim.valid?
      end
    ensure
      claim.form_step = original_step
    end

    private

    attr_reader :claim, :original_step

    delegate :full_submission_flow, to: :claim
  end
end
