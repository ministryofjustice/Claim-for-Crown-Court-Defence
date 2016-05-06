class TypedFeeSection < SitePrism::Section
  include Select2Helper

  element :select2_container, ".autocomplete", visible: false
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :case_numbers, "input.js-misc-fee-case-numbers"
  element :add_dates, ".fee-dates-row > a"
  section :dates, FeeDatesSection, ".fee-dates"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    rate.value.size > 0
  end
end
