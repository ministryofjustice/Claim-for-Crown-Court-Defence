class FixedFeeSection < SitePrism::Section
  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :input, 'input'
  end

  section :adjourned_appeals_committal_breaches, FeeSection, "#adjourned-appeals-committals-and-breaches > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_sentence, FeeSection, "#appeals-to-the-crown-court-against-sentence > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_conviction, FeeSection, "#appeals-to-the-crown-court-against-conviction > .fixed-fee-group"
  section :number_of_cases_uplift, FixedFeeCaseNumbersSection, "#number-of-cases-uplift > .fixed-fee-group"
  section :number_of_defendants_uplift, FeeSection, "#number-of-defendants-uplift > .fixed-fee-group"
  section :standard_appearance_fee, FeeSection, "#standard-appearance-fee > .fixed-fee-group"
  section :elected_case_not_proceeded, FeeSection, "#elected-case-not-proceeded > .fixed-fee-group"

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
