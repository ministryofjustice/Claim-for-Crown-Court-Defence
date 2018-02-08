class SupplierNumberSection < SitePrism::Section
  element :radio, 'input'
end

class SupplierNumbersSection < SitePrism::Section
  sections :supplier_numbers, SupplierNumberSection, '.block-label'

  def labels
    supplier_numbers.map(&:text)
  end
end

