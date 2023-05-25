module Claims
  class CreateDraft < ClaimActionsService
    def initialize(claim, validate:)
      super(claim, params: nil, validate:)
    end

    def call
      if already_saved?
        @error_code = :already_saved
        return result
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
