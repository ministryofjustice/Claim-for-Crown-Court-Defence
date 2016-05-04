class InterimFeeSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "select#claim_interim_fee_attributes_fee_type_id", visible: false

  #
  # TODO: elements to be completed once the UI has been rewritten
  #

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end
end
