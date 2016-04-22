class ExpensePresenter < BasePresenter
  presents :expense

  # def dates_attended_delimited_string
  #   expense.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  # end

  def amount
    h.number_to_currency(expense.amount)
  end

  def vat_amount
    h.number_to_currency(expense.vat_amount)
  end

  def total
    h.number_to_currency(expense.amount + expense.vat_amount)
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
    expense.expense_reason_other? ? 'inline' : 'none'
  end

end
