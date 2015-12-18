class ExpensePresenter < BasePresenter
  presents :expense

  def dates_attended_delimited_string
    expense.dates_attended.order(date: :asc).map(&:to_s).join(', ')
  end

 def amount
    h.number_to_currency(expense.amount)
 end
end
