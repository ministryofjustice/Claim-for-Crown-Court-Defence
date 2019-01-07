class FixedFeeSection < SitePrism::Section
  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :checkbox, 'input[type="checkbox"]', visible: false
  end

  section :adjourned_appeals_committals_and_breaches, FeeSection, "#adjourned-appeals-committals-and-breaches > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_sentence, FeeSection, "#appeals-to-the-crown-court-against-sentence > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_conviction, FeeSection, "#appeals-to-the-crown-court-against-conviction > .fixed-fee-group"
  section :number_of_cases_uplift, FixedFeeCaseNumbersSection, "#number-of-cases-uplift > .fixed-fee-group"
  section :number_of_defendants_uplift, FeeSection, "#number-of-defendants-uplift > .fixed-fee-group"
  section :standard_appearance_fee, FeeSection, "#standard-appearance-fee > .fixed-fee-group"
  section :elected_case_not_proceeded, FeeSection, "#elected-case-not-proceeded > .fixed-fee-group"

 #  sections :group, '.fixed-fee-group' do
 #   element :destroy, '.destroy:hidden'
 # end

  def checklist_labels
    checklist.map { |item| item.label.text if item.has_label? }
  end

  def checklist_item_for(label)
    checklist.find do |item|
      item.label.text.match?(Regexp.new(label, true))
    end
  end

  def toggle(label)
    checklist.each do |item|
      item.label.click if item.label.text.match?(Regexp.new(label, true))
    end
  end

  def check(label)
    page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end

  def set_quantity(fee, value = 1)
    fee_block = fee_block_for(fee)
    fee_block.quantity.set value
    fee_block.quantity.send_keys(:tab)
  end

  def fee_block_for(fee)
    send(fee.downcase.gsub(/ /, '_').gsub(/,/, '').to_sym)
  end
end
