class DisbursementSection < SitePrism::Section
  include Select2Helper

  element :select2_container, ".autocomplete", visible: false
  element :net_amount, "input.amount"
  element :vat_amount, "input.vat"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    net_amount.value.size > 0
  end
end
