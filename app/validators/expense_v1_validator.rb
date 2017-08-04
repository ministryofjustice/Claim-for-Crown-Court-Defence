class ExpenseV1Validator < BaseValidator
  def self.fields
    %i[
      expense_type
      quantity
      rate
    ]
  end

  def self.mandatory_fields
    [:claim]
  end

  private

  def validate_claim
    validate_presence(:claim, 'blank')
  end

  def validate_expense_type
    validate_presence(:expense_type, 'blank')
  end

  def validate_quantity
    validate_presence(:quantity, 'blank')
    validate_numericality(:quantity, 'numericality', 0, nil)
  end

  def validate_rate
    validate_presence(:rate, 'blank')
    validate_numericality(:rate, 'numericality', 0, nil)
  end
end
