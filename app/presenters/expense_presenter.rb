class ExpensePresenter < BasePresenter
  presents :expense

  # def dates_attended_delimited_string
  #   expense.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  # end

  def amount
    h.number_to_currency(expense.amount)
  end

  def vat_amount
    h.number_to_currency(expense.vat_amount || 0)
  end

  def total
    h.number_to_currency(expense.amount + expense.vat_amount)
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
    expense.try(:expense_reason).try(:reason)
  end


end
