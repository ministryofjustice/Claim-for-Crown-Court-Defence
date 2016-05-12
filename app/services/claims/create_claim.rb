module Claims
  class CreateClaim < ClaimActionsService

    def initialize(claim)
      self.claim = claim
      self.validate = true
    end

    def call
      if already_submitted?
        set_error_code(:already_submitted) and return
      end

      save_claim!(validate?)

      self
    end

    def action
      :new
    end

    def ga_args
      %w(event claim submit started)
    end
  end
end
