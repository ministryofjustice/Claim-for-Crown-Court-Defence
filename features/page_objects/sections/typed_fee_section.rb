class TypedFeeSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "tr:nth-of-type(1) > td:nth-of-type(1) .autocomplete", visible: false
  element :quantity, "tr:nth-of-type(1) input.quantity"
  element :rate, "tr:nth-of-type(1) input.rate"
  element :case_numbers, "tr:nth-of-type(1) input.js-misc-fee-case-numbers"
  element :add_dates, "tr:nth-of-type(1) > td:nth-of-type(5) > a"
  section :dates, FeeDatesSection, "tr.fee-dates"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    rate.value.size > 0
  end
end
