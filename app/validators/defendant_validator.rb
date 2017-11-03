class DefendantValidator < BaseValidator
  def self.fields
    %i[
      date_of_birth
      representation_orders
      first_name
      last_name
    ]
  end

  def self.mandatory_fields
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_date_of_birth
    validate_presence(:date_of_birth, 'blank')
    validate_on_or_before(10.years.ago, :date_of_birth, 'check')
    validate_on_or_after(120.years.ago, :date_of_birth, 'check')
  end

  def validate_representation_orders
    return if @record.claim.try(:api_draft?)

    # Will get validated by the sub-model validator RepresentationOrderValidator
    @record.representation_orders.build if @record.representation_orders.none?
  end

  def validate_first_name
    validate_presence(:first_name, 'blank')
    validate_max_length(:first_name, 40, 'max_length')
  end

  def validate_last_name
    validate_presence(:last_name, 'blank')
    validate_max_length(:last_name, 40, 'max_length')
  end
end
