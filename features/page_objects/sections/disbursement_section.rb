class DisbursementSection < SitePrism::Section
  include Select2Helper

  element :select2_container, ".autocomplete", visible: false
  element :net_amount, "input[data-calculator=net]"
  element :vat_amount, "input[data-calculator=vat]"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    net_amount.value.size > 0
  end
end
