class SupplierNumberSubModelValidator < BaseSubModelValidator
  def has_many_association_names
    [:supplier_numbers]
  end

  def suffix_error_fields?
    false
  end
end
