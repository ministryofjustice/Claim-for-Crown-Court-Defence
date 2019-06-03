class SupplierNumberPresenter < BasePresenter
  def supplier_label
    return supplier_number if postcode.blank?
    return "#{supplier_number} - (#{postcode})" if name.blank?
    "#{supplier_number} - #{name} (#{postcode})"
  end
end
