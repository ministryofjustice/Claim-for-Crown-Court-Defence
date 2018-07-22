class TypedFeeSection < SitePrism::Section
  element :select_input, "input.tt-input", visible: true
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :amount, nil
  element :case_numbers, "input.fx-fee-case-numbers"
  element :case_numbers_section, ".case_numbers_wrapper"
  element :add_dates, ".dates-wrapper .add_fields"
  element :numbered, ".fx-numberedList-number"
  section :dates, FeeDatesSection, ".fee-dates"

  # NOTE: the select list is hidden. Selection is done
  # by entering text into the input text field.
  def select_fee_type(name)
    fill_in(select_input[:id], with: name)
  end

  def populated?
    rate.value.size > 0
  end
end
