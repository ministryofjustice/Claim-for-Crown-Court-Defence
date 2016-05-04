class DisbursementSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "tr:nth-of-type(1) > td:nth-of-type(1) .autocomplete", visible: false
  element :net_amount, "tr:nth-of-type(1) input[data-calculator=net]"
  element :vat_amount, "tr:nth-of-type(1) input[data-calculator=vat]"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    net_amount.value.size > 0
  end
end
