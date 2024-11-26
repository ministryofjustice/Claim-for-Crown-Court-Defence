class CertificationValidator < BaseValidator
  class << self
    def mandatory_fields
      %i[certification_type_id certified_by certification_date]
    end
  end

  private

  def validate_certification_type_id
    return unless @record&.claim&.agfs? && @record&.claim.final?
    validate_presence(:certification_type_id, :blank)
  end

  def validate_certified_by
    validate_presence(:certified_by, :blank)
  end

  def validate_certification_date
    validate_presence(:certification_date, :blank)
    validate_on_or_after(@record.claim&.created_at, :certification_date, :after_claim_creation)
    validate_not_in_future(:certification_date)
  end
end
