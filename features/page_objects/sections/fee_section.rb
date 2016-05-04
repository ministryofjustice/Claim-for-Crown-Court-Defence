class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :add_dates, "td:nth-of-type(5) > a"
end
