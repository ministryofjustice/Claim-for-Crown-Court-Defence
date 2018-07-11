class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :add_dates, ".dates-wrapper .add_fields"
  element :total, "input.total"
end
