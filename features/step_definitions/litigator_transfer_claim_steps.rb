Then(/^I should be on the litigator new transfer claim page$/) do
  expect(@litigator_transfer_claim_form_page).to be_displayed
end

And(/^I fill in '(.*)' as the transfer fee total$/) do |total|
  @litigator_transfer_claim_form_page.transfer_fee.transfer_fee_total.set total
end

And(/^I choose the litigator type option '(.*)'$/) do |option|
  @litigator_transfer_claim_form_page.transfer_fee.litigator_type_original.click if option.downcase == 'original'
  @litigator_transfer_claim_form_page.transfer_fee.litigator_type_new.click if option.downcase == 'new'
end

And(/^I choose the elected case option '(.*)'$/) do |option|
  @litigator_transfer_claim_form_page.transfer_fee.elected_case_yes.click if option.downcase == 'yes'
  @litigator_transfer_claim_form_page.transfer_fee.elected_case_no.click if option.downcase == 'no'
end

And(/^I select the transfer stage '(.*)'$/) do |name|
  @litigator_transfer_claim_form_page.transfer_fee.select_transfer_stage(name)
end

And(/^I enter the transfer date '(.*)'$/) do |date_string|
  @litigator_transfer_claim_form_page.transfer_fee.transfer_date.set_date date_string
end

And(/^I select a case conclusion of '(.*)'$/) do |name|
  @litigator_transfer_claim_form_page.transfer_fee.select_case_conclusion(name)
end
