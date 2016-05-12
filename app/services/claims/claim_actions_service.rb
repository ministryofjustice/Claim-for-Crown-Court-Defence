module Claims
  class ClaimActionsService

    attr_accessor :claim, :params, :validate

    def self.call(*args)
      new(*args).call
    end

    def ga_args
      []
    end

    def draft?
      false
    end

    def action
    end

    def result
      @result ||= ClaimActionsResult.new
    end


    private

    def validate?
      self.validate
    end

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
        claim.force_validation = validation
        rollback! unless claim.save
      end
    end

    def rollback!
      set_error_code(:rollback)
      raise ActiveRecord::Rollback
    end

    def already_submitted?
      claim.class.where(form_id: claim.form_id).where.not(last_submitted_at: nil).any?
    end

    def already_saved?
      claim.class.where(form_id: claim.form_id).any?
    end

    def set_error_code(code)
      @result = ClaimActionsResult.new(success: false, error_code: code)
    end

  end
end
