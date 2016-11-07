class DefendantValidator < BaseValidator

  def self.fields
    [
      :date_of_birth,
      :representation_orders,
      :first_name,
      :last_name
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
    return unless requires_dob?
    validate_presence(:date_of_birth, 'blank')
    validate_not_after(10.years.ago, :date_of_birth, "check")
    validate_not_before(120.years.ago, :date_of_birth, "check")
  end

  def validate_representation_orders
    return if @record.claim.try(:api_draft?)

    # Will get validated by the sub-model validator RepresentationOrderValidator
    if @record.representation_orders.none?
      @record.representation_orders.build
    end
  end

  def validate_first_name
    validate_presence(:first_name, 'blank')
    validate_max_length(:first_name, 50, 'max_length')
  end

  def validate_last_name
    validate_presence(:last_name, 'blank')
    validate_max_length(:last_name, 50, 'max_length')
  end


  # local helpers
  #
  def requires_dob?
    @record.claim&.case_type&.requires_defendant_dob?
  end
end
