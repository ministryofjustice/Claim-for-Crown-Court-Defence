class ExpensePresenter < BasePresenter
  presents :expense

  def dates_attended_delimited_string
    expense.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  end

  def amount
    h.number_to_currency(expense.amount)
  end

  def name
    if expense.expense_type.blank?
      "Not selected"
    else
      expense.expense_type.name
    end
  end

end
