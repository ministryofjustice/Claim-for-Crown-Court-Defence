class LgfsTransferFeeSection < SitePrism::Section
  element :days_total, "input#claim_actual_trial_length"
  element :ppe_total, "input.quantity"
  element :amount, "input.fee-amount"
end
