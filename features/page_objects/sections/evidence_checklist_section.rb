class EvidenceChecklistSection < SitePrism::Section
  sections :items, ".cc-evidence-checklist .govuk-checkboxes__item" do
    element :input, "input"
    element :label, "label"
  end

  def labels
    items_with_labels.map { |item| item.label.text }
  end

  def check(label)
    item = item_for(label)
    item.label.click unless checkbox_for(item).checked?
  end

  def checkbox_checked?(label)
    checkbox_for(item_for(label)).checked?
  end

  def items_with_labels
    items.select { |item| item.has_label? }.compact
  end

  private

  def item_for(label)
    items_with_labels.find do |item|
      item.label.text.strip.casecmp?(label.strip)
    end || raise(Capybara::ElementNotFound, "Could not find evidence checklist item #{label.inspect}")
  end

  def checkbox_for(item)
    item.find("input[type='checkbox']", visible: :all)
  end
end
