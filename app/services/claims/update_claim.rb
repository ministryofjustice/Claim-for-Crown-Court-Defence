module Claims
  class UpdateClaim < ClaimActionsService
    def initialize(claim, params:)
      self.claim = claim
      self.params = params
      self.validate = true
    end

    def call
      if already_submitted?
        set_error_code(:already_submitted) and return
      end

      claim.assign_attributes(params)
      claim.source = 'api_web_edited' if claim.from_api?

      save_claim!(validate?)

      result
    end

    def action
      :edit
    end
  end
end
