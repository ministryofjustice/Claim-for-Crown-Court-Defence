class ExpensePresenter < BasePresenter
  presents :expense

  def amount
    h.number_to_currency(expense.amount.to_f)
  end

  def vat_amount
    h.number_to_currency(expense.vat_amount.to_f)
  end

  def total
    h.number_to_currency(expense.amount.to_f + expense.vat_amount.to_f)
  end

  def distance
    h.number_with_precision(expense.distance, precision: 2, strip_insignificant_zeros: true)
  end

  def hours
    h.number_with_precision(expense.hours, precision: 1, strip_insignificant_zeros: true)
  end

  def name
    if expense.expense_type.blank?
      "Not selected"
    else
      expense.expense_type.name
    end
  end

  def pretty_date
    expense.date.nil? ? 'Date not set' : expense.date.strftime(Settings.date_format)
  end

  def display_reason_text_css
    expense.expense_reason_other? ? 'inline-block' : 'none'
  end

  def reason
    expense.displayable_reason_text || 'Not provided'
  end

  def mileage_rate
    expense.mileage_rate&.name || 'n/a'
  end
end
