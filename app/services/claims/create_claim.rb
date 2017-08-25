module Claims
  class CreateClaim < ClaimActionsService
    def initialize(claim)
      self.claim = claim
      self.validate = true
    end

    def call
      if already_submitted?
        set_error_code(:already_submitted)
        return result
      end

      save_claim!(validate?)

      result
    end

    def action
      :new
    end
  end
end
