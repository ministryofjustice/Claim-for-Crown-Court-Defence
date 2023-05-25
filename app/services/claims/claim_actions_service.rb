module Claims
  class ClaimActionsService
    attr_accessor :claim, :params, :validate

    def initialize(claim, validate:, params:)
      @claim = claim
      @validate = validate
      @params = params
      @error_code = nil
    end

    def self.call(claim, **kwargs)
      new(claim, **kwargs).call
    end

    def draft?
      false
    end

    def action; end

    def result
      @result = ClaimActionsResult.new(self, error_code: @error_code)
    end

    def validate?
      validate
    end

    private

    def save_claim!(validation)
      claim.class.transaction do
        claim.save
        claim.force_validation = validation

        if claim.valid?
          claim.update_claim_document_owners
        else
          rollback!
        end
      end
    end

    def save_draft!(validation)
      claim.class.transaction do
        claim.save
        claim.force_validation = validation
        rollback! unless claim.valid?
      end
    end

    def update_source
      claim.source = 'api_web_edited' if claim.from_api?
    end

    def rollback!
      @error_code = :rollback
      raise ActiveRecord::Rollback
    end

    def already_submitted?
      claim.last_submitted_at.present?
    end

    def already_saved?
      claim.class.where(form_id: claim.form_id).any?
    end
  end
end
