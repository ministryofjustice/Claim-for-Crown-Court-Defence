# TODO: use for fixed fee and basic fee checkboxes too if possible
class CheckboxFeeSection < SitePrism::Section
  sections :checklist, '.multiple-choice' do
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
    page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end

  def set_quantity(label, value = 1)
    fee_block = fee_block_for(label)
    fee_block.quantity.set value
    fee_block.quantity.send_keys(:tab)
  end

  def fee_block_section(label)
    label.downcase.tr('(),','').tr(' ','_')
  end

  def fee_block_id(label)
    '#'.concat(fee_block_section(label).tr('_','-'))
  end

  # requires a FeeSection siteprism section object for each checkbox fee section
  def fee_block_for(label)
    send(fee_block_section(label).to_sym)
  end
end