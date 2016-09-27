class DisbursementSection < SitePrism::Section
  include SelectHelper

  element :select_container, "select.typeahead", visible: false
  element :net_amount, "input.amount"
  element :vat_amount, "input.vat"

  def select_fee_type(name)
    id = select_container[:id]
    select name, from: id
  end

  def populated?
    net_amount.value.size > 0
  end
end
