class TypedFeeSection < SitePrism::Section
  sections :select_options, "select.js-fee-type > option" do end
  element :select_input, "input.tt-input", visible: true
  section :govuk_fee_type_autocomplete, CommonAutocomplete, ".cc-fee-type"
  element :govuk_fee_type_autocomplete_input, ".cc-fee-type input", visible: true
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper .govuk-hint"
  element :calc_help_text, ".fee-calc-help-wrapper"
  element :rate, "input.rate"
  element :amount, nil
  element :case_numbers, "input.fx-fee-case-numbers"
  element :case_numbers_section, ".case_numbers_wrapper"
  element :add_dates, ".dates-wrapper .add_fields"
  element :numbered, ".fx-numberedList-number"
  section :dates, GovukDateSection, ".fee-dates"

  # NOTE: the select list is hidden. Selection is done
  # by entering text into the input text field.
  def select_fee_type(name)
    fill_in(select_input[:id], with: name)
  end

  def fee_type_descriptions
    select_options.map(&:text).reject(&:empty?)
  end

  def populated?
    select_input.value.present?
  end

  def govuk_element_populated?
    govuk_fee_type_autocomplete_input.value.present?
  end
end
