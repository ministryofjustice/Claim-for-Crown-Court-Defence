class ExpenseSection < SitePrism::Section
  element :expense_type_dropdown, "#claim_expenses_attributes_0_expense_type_id"
  element :destination, "#claim_expenses_attributes_0_location"
  element :quantity, "#claim_expenses_attributes_0_distance"
  element :reason_for_travel_dropdown, "#claim_expenses_attributes_0_reason_id"
  element :amount, "#claim_expenses_attributes_0_amount"

  section :expense_date, "fieldset#expense_1_date" do
    include DateHelper
    element :day, "input#claim_expenses_attributes_0_date_dd"
    element :month, "input#claim_expenses_attributes_0_date_mm"
    element :year, "input#claim_expenses_attributes_0_date_yyyy"
  end
end
