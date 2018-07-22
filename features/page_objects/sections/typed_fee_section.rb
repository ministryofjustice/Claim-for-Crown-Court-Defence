class TypedFeeSection < SitePrism::Section
  include SelectHelper

  element :select_container, "select.typeahead", visible: false
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :amount, nil
  element :case_numbers, "input.fx-fee-case-numbers"
  element :case_numbers_section, ".case_numbers_wrapper"
  element :add_dates, ".dates-wrapper .add_fields"
  element :numbered, ".fx-numberedList-number"
  section :dates, FeeDatesSection, ".fee-dates"

  # FIXME: does not seem to work when selecting an Appeal against a conviction plus its uplift equivalent
  def select_fee_type(name)
    from = select_container[:id]
    # find(:select, from).find(:option, name).select_option
    select(name, from: from)
  end

  def populated?
    rate.value.size > 0
  end
end
