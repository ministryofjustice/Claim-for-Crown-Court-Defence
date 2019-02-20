class DisbursementSection < SitePrism::Section
  include SelectHelper

  section :disbursement_select, CommonAutocomplete, ".js-typeahead"
  element :net_amount, "input.amount"
  element :vat_amount, "input.vat"

  def populated?
    net_amount.value.size > 0
  end
end
