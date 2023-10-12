class LGFSTransferFeeSection < SitePrism::Section
  element :days_total, "input.js-fee-calculator-days"
  element :ppe_total, "input.js-fee-calculator-ppe"
  element :amount, "input.fee-amount"
end
