class CertificationValidator < BaseValidator
  class << self
    def mandatory_fields
      %i[certification_type_id certified_by certification_date]
    end
  end

  private

  def validate_certification_type_id
    validate_presence(:certification_type_id, :blank) if @record&.claim&.agfs?
  end

  def validate_certified_by
    validate_presence(:certified_by, :blank)
  end

  def validate_certification_date
    validate_presence(:certification_date, :blank)
    validate_on_or_after(@record.claim&.created_at, :certification_date, :after_claim_creation)
    validate_on_or_before(Date.today, :certification_date, :not_in_the_future)
  end
end
