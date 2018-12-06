class FixedFeeSection < SitePrism::Section
  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :input, 'input'
  end

  def checklist_labels
    checklist.map { |item| item.label.text if item.has_label? }
  end


  def toggle(label)
    checklist.each do |item|
      item.label.click if item.label.text.match?(Regexp.new(label, true))
    end
  end
end
