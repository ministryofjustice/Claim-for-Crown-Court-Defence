class SupplierNumberSection < SitePrism::Section
  element :radio, 'label'
end

class SupplierNumberRadioSection < SitePrism::Section
  sections :supplier_numbers, SupplierNumberSection, '.multiple-choice'
end
