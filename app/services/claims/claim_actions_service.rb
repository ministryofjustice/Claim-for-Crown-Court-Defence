module Claims
  class ClaimActionsService
    attr_accessor :claim, :params, :validate

    def self.call(*args)
      new(*args).call
    end

    def draft?
      false
    end

    def action; end

    def result
      @result ||= ClaimActionsResult.new(self)
    end

    def validate?
      validate
    end

    private

    def save_claim!(validation)
      claim.class.transaction do
        clear_destroyed_fixed_fees
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
        clear_destroyed_fixed_fees
        claim.force_validation = validation
        rollback! unless claim.save
      end
    end

    def update_source
      claim.source = 'api_web_edited' if claim.from_api?
      claim.source = 'json_import_web_edited' if claim.from_json_import?
    end

    def rollback!
      set_error_code(:rollback)
      raise ActiveRecord::Rollback
    end

    def already_submitted?
      claim.last_submitted_at.present?
    end

    def already_saved?
      claim.class.where(form_id: claim.form_id).any?
    end

    def set_error_code(code)
      @result = ClaimActionsResult.new(self, success: false, error_code: code)
    end

    def clear_destroyed_fixed_fees
      return unless can_parse_params
      JSON.parse(params.to_json)['fixed_fees_attributes'].each do |array|
        fixed_fee = array[1]
        claim.fixed_fees.delete(fixed_fee['id']) if fixed_fee['id'].present? && fixed_fee['_destroy'].true?
      end
    end

    def can_parse_params
      params.present? && params['form_step'].eql?('fixed_fees') && claim.fixed_fees.present? && claim.agfs?
    end
  end
end
