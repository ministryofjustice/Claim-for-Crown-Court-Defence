Then(/^I should be on the litigator new transfer claim page$/) do
  expect(@litigator_transfer_claim_form_page).to be_displayed
end

And(/^I choose the litigator type option '(.*)'$/) do |option|
  @litigator_transfer_claim_form_page.transfer_detail.litigator_type_original.click if option.downcase == 'original'
  @litigator_transfer_claim_form_page.transfer_detail.litigator_type_new.click if option.downcase == 'new'
  wait_for_ajax
end

And(/^I choose the elected case option '(.*)'$/) do |option|
  @litigator_transfer_claim_form_page.transfer_detail.elected_case_yes.click if option.downcase == 'yes'
  @litigator_transfer_claim_form_page.transfer_detail.elected_case_no.click if option.downcase == 'no'
  wait_for_ajax
end

And(/^I select the transfer stage '(.*)'$/) do |name|
  @litigator_transfer_claim_form_page.transfer_stage.choose_autocomplete_option(name)
  wait_for_ajax
end

And(/^I enter the transfer date '(.*)'$/) do |date_string|
  @litigator_transfer_claim_form_page.transfer_detail.transfer_date.set_date date_string
end

And('I enter the transfer date {int} years ago') do |years|
  date = years.years.ago.strftime('%d-%m-%Y')
  @litigator_transfer_claim_form_page.transfer_detail.transfer_date.set_date date
end

And(/^I select a case conclusion of '(.*)'$/) do |name|
  @litigator_transfer_claim_form_page.wait_until_case_conclusion_visible
  @litigator_transfer_claim_form_page.case_conclusion.choose_autocomplete_option(name)
end

Then(/^the transfer fee amount should be populated with '(\d+\.\d+)'$/) do |amount|
  patiently do
    expect(@litigator_transfer_claim_form_page.transfer_fee).to have_amount
    expect(@litigator_transfer_claim_form_page.transfer_fee.amount.value).to eql amount
  end
end

Then(/^I should (not )?see the days claimed field$/) do |negate|
  if negate
    expect(@litigator_transfer_claim_form_page.transfer_fee).to_not have_days_total
  else
    expect(@litigator_transfer_claim_form_page.transfer_fee).to have_days_total
  end
end

Then(/^I should (not )?see the ppe field$/) do |negate|
  if negate
    expect(@litigator_transfer_claim_form_page.transfer_fee).to_not have_ppe_total
  else
    expect(@litigator_transfer_claim_form_page.transfer_fee).to have_ppe_total
  end
end

Then(/^the transfer fee should have its price_calculated value set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  expect(claim.transfer_fee.price_calculated).to eql true
end
