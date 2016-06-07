class DisbursementValidator < BaseValidator
  def self.fields
    [
      :disbursement_type,
      :net_amount,
      :vat_amount
    ]
  end

  def self.mandatory_fields
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_disbursement_type
    validate_presence(:disbursement_type, 'blank')
  end

  def validate_net_amount
    validate_presence_and_numericality_for(:net_amount) || validate_zero_or_negative(:net_amount, 'zero_or_negative')
  end

  def validate_vat_amount
    validate_presence_and_numericality_for(:vat_amount) || validate_amount_greater_than(:vat_amount, :net_amount, 'greater_than')
  end

  def validate_presence_and_numericality_for(field)
    validate_presence(field, 'blank')
    validate_numericality(field, 0, nil, 'numericality')
  end
end
