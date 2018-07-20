class EvidenceChecklistSection < SitePrism::Section
  sections :items, ".multiple-choice" do
    element :input, "input"
    element :label, "label"
  end

  def items_with_labels
    items.select { |item| item.has_label? }.compact
  end

  def labels
    items_with_labels.map { |item| item.label.text }
  end

  def check(label)
    items_with_labels.each do |item|
      item.label.trigger('click') if item.label.text.match?(Regexp.new(label, true))
    end
  end
end
