class DisbursementValidator < BaseValidator
  def self.fields
    %i[
      disbursement_type_id
      net_amount
      vat_amount
    ]
  end

  def self.mandatory_fields
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
    add_error(:claim, 'invalid_fee_scheme') if @record&.claim&.agfs?
  end

  def validate_disbursement_type_id
    validate_belongs_to_object_presence(:disbursement_type, :blank)
  end

  def validate_net_amount
    validate_presence_and_numericality_govuk_formbuilder(:net_amount, minimum: 0.1)
  end

  def validate_vat_amount
    validate_vat_numericality_govuk_formbuilder(:vat_amount, lower_than_field: :net_amount, allow_blank: false)
  end
end
