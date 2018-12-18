class FixedFeeSection < SitePrism::Section
  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :input, 'input'

  end
  section :adjourned_appeals_committal_breaches, FeeSection, ".fixed-fee-group"
  section :appeals_to_the_crown_court_against_sentence, FeeSection, ".fixed-fee-group"
  section :number_of_cases_uplift, FeeSection, ".fixed-fee-group"
  section :number_of_defendants_uplift, FeeSection, ".fixed-fee-group"
  section :standard_appearance_fee, FeeSection, ".fixed-fee-group"

  def checklist_labels
    checklist.map { |item| item.label.text if item.has_label? }
  end

  def toggle(label)
    checklist.each do |item|
      item.label.click if item.label.text.match?(Regexp.new(label, true))
    end
  end

  def set_quantity(fee, value = 1)
    fee_block = fee_block_for(fee)
    fee_block.quantity.set value
    fee_block.quantity.send_keys(:tab)
  end

  def fee_block_for(fee)
    send(fee.downcase.gsub(/ /, '_').to_sym)
  end
end
