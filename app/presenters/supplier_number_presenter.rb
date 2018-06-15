class SupplierNumberPresenter < BasePresenter
  def supplier_label
    return supplier_number unless postcode.present?
    "#{supplier_number} (#{postcode})"
  end
end
