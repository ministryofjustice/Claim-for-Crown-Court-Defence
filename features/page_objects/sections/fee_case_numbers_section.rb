class FeeCaseNumbersSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :case_numbers, "input.js-basic-fee-case-numbers"
end
