class LgfsGraduatedFeeSection < SitePrism::Section
  section :date, CommonDateSection, ".form-date"
  element :actual_trial_length, "input#actual_trial_length"
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper span.form-hint"
  element :amount, ".fee-amount"
end
