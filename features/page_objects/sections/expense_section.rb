class ExpenseSection < SitePrism::Section
  #
  # TODO: Fix this.
  # This will only work for 1 expense. If there are more than 1 expense,
  # it will always populate the first expense, because the way we are referencing
  # the elements by ID pointing to the first (zero-index) one.
  #
  element :expense_type_dropdown, "#claim_expenses_attributes_0_expense_type_id"
  element :destination_label, ".fx-establishment-select label"
  element :destination, "#expense_1_location"
  element :distance, "#expense_1_distance"
  element :reason_for_travel_dropdown, "#claim_expenses_attributes_0_reason_id"
  element :other_reason_input, "#expense_1_reason_text"
  element :amount, "#expense_1_amount"
  element :vat_amount, "#expense_1_vat_amount"
  element :mileage_20, ".fx-travel-mileage .fx-travel-mileage-bike label"
  element :mileage_25, ".fx-travel-mileage .fx-travel-mileage-car label:first"
  element :mileage_45, ".fx-travel-mileage .fx-travel-mileage-bike label:last"

  section :expense_date, "#expense_1_date" do
    include DateHelper
    element :day, "input#claim_expenses_attributes_0_date_dd"
    element :month, "input#claim_expenses_attributes_0_date_mm"
    element :year, "input#claim_expenses_attributes_0_date_yyyy"
  end
end
