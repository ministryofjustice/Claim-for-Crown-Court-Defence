class FixedFeeCaseNumbersSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :case_numbers, "input.js-fixed-fee-case-numbers"
end
