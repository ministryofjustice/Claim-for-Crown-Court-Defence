module Claims
  class UpdateDraft < ClaimActionsService
    def initialize(claim, params:, validate:)
      super(claim, params:, validate:)
    end

    def call
      claim.assign_attributes(params)
      update_source

      save_draft!(validate?)

      result
    end

    def action
      :edit
    end
  end
end
