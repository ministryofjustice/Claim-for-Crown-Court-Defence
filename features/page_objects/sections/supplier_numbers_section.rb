class SupplierNumberSection < SitePrism::Section
  element :radio, 'input'
end

class SupplierNumberRadioSection < SitePrism::Section
  sections :supplier_numbers, SupplierNumberSection, '.block-label'
end
