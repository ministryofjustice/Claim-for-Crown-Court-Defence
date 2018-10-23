class LgfsFixedFeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper span.form-hint"
  element :rate, "input.rate"
  element :total, ".fee-amount"
  section :date, CommonDateSection, ".form-date"
end
