class TypedFeeSection < SitePrism::Section
  include SelectHelper

  element :select_container, "select.typeahead", visible: false
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :amount, nil
  element :case_numbers, "input.fx-fee-case-numbers"
  element :add_dates, ".fee-dates-row > a"
  section :dates, FeeDatesSection, ".fee-dates"

  def select_fee_type(name)
    id = select_container[:id]
    select name, from: id
  end

  def populated?
    rate.value.size > 0
  end
end
