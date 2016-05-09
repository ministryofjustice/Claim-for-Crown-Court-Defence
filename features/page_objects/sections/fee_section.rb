class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :add_dates, ".fee-dates-row > a"
end
