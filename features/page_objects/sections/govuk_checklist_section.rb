class GovukChecklistSection < SitePrism::Section
  sections :checklist, '.basic-fees-checklist .govuk-checkboxes__item' do
    element :checkbox, '.govuk-checkboxes__input', visible: false
    element :label, '.govuk-label'
  end

  def checklist_labels
    checklist.map { |item| item.label.text if item.has_label? }
  end

  def checklist_item_for(label)
    checklist.find do |item|
      item.label.text.match?(Regexp.new(Regexp.escape(label), true))
    end
  end

  def check(label)
    page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end
end
