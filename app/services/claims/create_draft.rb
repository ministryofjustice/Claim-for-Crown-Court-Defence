module Claims
  class CreateDraft < ClaimActionsService
    def initialize(claim, validate:)
      self.claim = claim
      self.validate = validate
    end

    def call
      if already_saved?
        set_error_code(:already_saved) and return
      end

      save_draft!(validate?)

      result
    end

    def draft?
      true
    end

    def action
      :new
    end
  end
end
