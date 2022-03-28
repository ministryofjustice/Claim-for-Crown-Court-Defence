class LGFSGraduatedFeeSection < SitePrism::Section
  section :date, CommonDateSection, ".form-date"
  element :actual_trial_length, "input#actual_trial_length"
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper .govuk-hint"
  element :amount, ".fee-amount"
end
