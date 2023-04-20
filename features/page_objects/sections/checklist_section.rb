class ChecklistSection < SitePrism::Section
  sections :checklist, '.multiple-choice, .govuk-checkboxes__item' do
    element :label, 'label'
    element :checkbox, 'input[type="checkbox"]', visible: false
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
    parent_page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    parent_page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end
end
