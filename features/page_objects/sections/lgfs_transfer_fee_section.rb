class LgfsTransferFeeSection < SitePrism::Section
  element :days, "input#claim_actual_trial_length"
  element :ppe_total, "input.quantity"
  element :amount, "input.fee-amount"
end
