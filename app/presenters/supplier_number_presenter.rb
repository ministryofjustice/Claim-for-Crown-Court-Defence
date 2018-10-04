class SupplierNumberPresenter < BasePresenter
  def supplier_label
    return supplier_number unless postcode.present?
    return "#{supplier_number} - (#{postcode})" unless name.present?
    "#{supplier_number} - #{name} (#{postcode})"
  end
end
