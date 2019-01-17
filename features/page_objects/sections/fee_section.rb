class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :quantity_hint, ".quantity_wrapper span.form-hint"
  element :calc_help_text, ".fee-calc-help-wrapper"
  element :add_dates, ".dates-wrapper .add_fields"
  element :total, "input.total" # needed?
end
