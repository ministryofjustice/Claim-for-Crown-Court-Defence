class ExpenseValidator < BaseClaimValidator

  def self.fields
    [
      :expense_type,
      :quantity,
      :rate
    ]
  end

  private

  def validate_expense_type
    validate_presence(:expense_type, 'blank')
  end

  def validate_quantity
    validate_presence(:quantity, 'blank')
    validate_numericality(:quantity, 0, nil, 'numericality')
  end

  def validate_rate
    validate_presence(:rate, 'blank')
    validate_numericality(:rate, 0, nil, 'numericality')
  end

end
