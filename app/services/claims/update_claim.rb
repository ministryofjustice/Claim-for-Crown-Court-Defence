module Claims
  class UpdateClaim < ClaimActionsService
    def initialize(claim, params:)
      super(claim, params:, validate: true)
    end

    def call
      if already_submitted?
        @error_code = :already_submitted
        return result
      end

      claim.assign_attributes(params)
      update_source

      save_claim!(validate?)

      result
    end

    def action
      :edit
    end
  end
end
