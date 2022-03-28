class LGFSFixedFeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper .govuk-hint"
  element :rate, "input.rate"
  element :total, ".fee-net-amount"
  section :date, GovukDateSection, ".govuk-date-input"
end
