class FixedFeeCaseNumbersSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper span.form-hint"
  element :rate, "input.rate"
  element :case_numbers, "input.js-fixed-fee-case-numbers"
end
