Then(/^I should be on the advocate supplementary new claim page$/) do
  expect(@advocate_supplementary_claim_form_page).to be_displayed
end

Then(/^I choose the '(.*?)' miscellaneous fee(?: with quantity of '(.*?)')?$/) do |label, quantity|
  @advocate_supplementary_claim_form_page.miscellaneous_fees.check(label)
  wait_for_ajax
  @advocate_supplementary_claim_form_page.miscellaneous_fees.set_quantity(label, quantity || 1)
  wait_for_ajax
end

Then("the following miscellaneous fee checkboxes should exist:") do |table|
  fee_type_descriptions = table.symbolic_hashes.map{ |el| el[:fee_description] }
  expect(@advocate_supplementary_claim_form_page.miscellaneous_fees.checklist_labels).to match_array(fee_type_descriptions)
end

Then(/^the following supplementary fee details should exist:$/) do |table|
  table.hashes.each do |row|
    fee_block = @advocate_supplementary_claim_form_page.fee_block_for("#{row['section']}_fees", row['fee_description'])

    expect(fee_block.rate.value).to eql row['rate']
    expect(fee_block.quantity_hint).to have_text(row['hint']) if row.keys.include?('hint')
    expect(fee_block).to have_calc_help_text if row.keys.include?('help') && row['help'].eql?('true')
    expect(fee_block).to_not have_calc_help_text if row.keys.include?('help') && !row['help'].eql?('true')
  end
end
