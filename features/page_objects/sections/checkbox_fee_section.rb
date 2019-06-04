require_relative 'checklist_section'
class CheckboxFeeSection < ChecklistSection
  def set_quantity(label, value = 1)
    fee_block = fee_block_for(label)
    fee_block.quantity.set value
    fee_block.quantity.send_keys(:tab)
  end

  # NOTE: enforces a standard naming convention for siteprism section names
  # whereby it should be named after the label but with thte following
  # translations.
  def fee_block_section(label)
    label.downcase.tr(' ', '_').tr(',()', '').gsub(/\+/,'_plus')
  end

  def fee_block_id(label)
    '#'.concat(fee_block_section(label).tr('_','-'))
  end

  # requires a FeeSection siteprism section object for each checkbox fee section
  def fee_block_for(label)
    send(fee_block_section(label).to_sym)
  end
end