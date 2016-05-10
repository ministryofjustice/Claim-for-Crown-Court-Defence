And(/^My provider has supplier numbers$/) do
  %w(1A222Z 2B333Z).each do |number|
    @litigator.provider.supplier_numbers << SupplierNumber.new(supplier_number: number)
  end
end

Then(/^I should be on the litigator new claim page$/) do
  expect(@litigator_claim_form_page).to be_displayed
end

Then(/^I should be on the litigator new interim claim page$/) do
  expect(@interim_claim_form_page).to be_displayed
end

Then(/^I should be on the litigator new transfer claim page$/) do
  expect(@transfer_claim_form_page).to be_displayed
end


When(/^I select the supplier number '(.*)'$/) do |number|
  @litigator_claim_form_page.select_supplier_number(number)
end

And(/^I select the offence class '(.*)'$/) do |name|
  @litigator_claim_form_page.select_offence_class(name)
end

And(/^I fill '(.*)' as the fixed fee total$/) do |total|
  @litigator_claim_form_page.fixed_fee_total.set total
end

And(/^I enter the case concluded date$/) do
  @litigator_claim_form_page.case_concluded_date.set_date "2016-01-01"
end

And(/^I add a miscellaneous fee '(.*)'$/) do |name|
  @litigator_claim_form_page.add_misc_fee_if_required
  @litigator_claim_form_page.miscellaneous_fees.last.select_fee_type name
  @litigator_claim_form_page.miscellaneous_fees.last.amount.set "135.78"
end

And(/^I add a Case uplift fee with case numbers '(.*)'$/) do |case_numbers|
  step "I add a miscellaneous fee 'Case uplift'"
  @litigator_claim_form_page.miscellaneous_fees.last.case_numbers.set case_numbers
end

And(/^I add (?:a|another) disbursement '(.*)' with net amount '(.*)' and vat amount '(.*)'$/) do |name, net_amount, vat_amount|
  @litigator_claim_form_page.add_disbursement_if_required
  @litigator_claim_form_page.disbursements.last.select_fee_type name
  @litigator_claim_form_page.disbursements.last.net_amount.set net_amount
  @litigator_claim_form_page.disbursements.last.vat_amount.set vat_amount
end

And(/^I select an interim fee type of '(.*)'$/) do |name|
  @interim_claim_form_page.interim_fee.select_fee_type(name)
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

Then(/^I select a case conclusion of '(.*)'$/) do |name|
  @transfer_claim_form_page.select_case_conclusion(name)
end
