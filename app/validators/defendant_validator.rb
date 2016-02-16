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
    validate_presence(:date_of_birth, 'blank')
    validate_not_after(10.years.ago, :date_of_birth, "check")
    validate_not_before(120.years.ago, :date_of_birth, "check")
  end

  def validate_representation_orders
    unless @record.claim && @record.claim.api_draft?
      if @record.representation_orders.none?
        add_error(:representation_orders, 'no_reporder')
      end
    end
  end

  def validate_first_name
    validate_presence(:first_name, 'blank')
  end

  def validate_last_name
    validate_presence(:last_name, 'blank')
  end

end
