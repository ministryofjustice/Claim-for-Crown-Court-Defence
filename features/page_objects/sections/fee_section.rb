class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper span.form-hint"
  element :rate, "input.rate"
  element :add_dates, ".dates-wrapper .add_fields"
  element :total, "input.total"
end
