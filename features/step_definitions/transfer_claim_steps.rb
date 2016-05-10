Then(/^I should be on the litigator new transfer claim page$/) do
  expect(@transfer_claim_form_page).to be_displayed
end

And(/^I fill in '(.*)' as the transfer fee total$/) do |total|
  @transfer_claim_form_page.transfer_fee_total.set total
end

And(/^I choose the litigator type option '(.*)'$/) do |option|
  @transfer_claim_form_page.litigator_type_new.click if option.downcase == 'original'
  @transfer_claim_form_page.litigator_type_new.click if option.downcase == 'new'
end

And(/^I choose the elected case option '(.*)'$/) do |option|
  @transfer_claim_form_page.elected_case_yes.click if option.downcase == 'yes'
  @transfer_claim_form_page.elected_case_no.click if option.downcase == 'no'
end

And(/^I select the transfer stage '(.*)'$/) do |name|
  @transfer_claim_form_page.select_transfer_stage(name)
end

And(/^I enter the transfer date '(.*)'$/) do |date_string|
  @transfer_claim_form_page.transfer_date.set_date date_string
end

And(/^I select a case conclusion of '(.*)'$/) do |name|
  @transfer_claim_form_page.select_case_conclusion(name)
end

And(/^I add a miscellaneous fee '(.*)' to the transfer claim$/) do |name|
  @transfer_claim_form_page.add_misc_fee_if_required
  @transfer_claim_form_page.miscellaneous_fees.last.select_fee_type name
  @transfer_claim_form_page.miscellaneous_fees.last.rate.set "135.78"
end

And(/^I add a Case uplift fee with case numbers '(.*)' to the transfer claim$/) do |case_numbers|
  step "I add a miscellaneous fee 'Case uplift' to the transfer claim"
  @transfer_claim_form_page.miscellaneous_fees.last.case_numbers.set case_numbers
end
