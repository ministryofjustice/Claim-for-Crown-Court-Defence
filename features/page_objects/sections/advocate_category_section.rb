class AdvocateCategorySection < SitePrism::Section
  element :radio, 'label'
end

class AdvocateCategoryRadioSection < SitePrism::Section
  sections :advocate_categories, AdvocateCategorySection, '.multiple-choice'

  def radio_labels
    advocate_categories.map { |category| category.text }
  end
end
