class ExpenseSection < SitePrism::Section
  element :expense_type_dropdown, ".fx-travel-expense-type select"
  element :destination_label, ".fx-establishment-select label"
  element :destination, ".fx-travel-location .fx-location-model"
  element :distance, ".fx-travel-distance input"
  element :reason_for_travel_dropdown, ".fx-travel-reason select"
  element :other_reason_input, ".fx-travel-reason-other input"
  element :amount, ".fx-travel-net-amount input"
  element :vat_amount, ".fx-travel-vat-amount input"
  element :mileage_20, ".fx-travel-mileage.fx-travel-mileage-bike label"
  element :mileage_25, ".fx-travel-mileage.fx-travel-mileage-car label:first"
  element :mileage_45, ".fx-travel-mileage.fx-travel-mileage-bike label:last"

  section :expense_date, GovukDateSection, ".fx-travel-date"
end
