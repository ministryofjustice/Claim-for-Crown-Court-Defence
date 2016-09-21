And(/^My provider has supplier numbers$/) do
  %w(1A222Z 2B333Z).each do |number|
    @litigator.provider.lgfs_supplier_numbers << SupplierNumber.new(supplier_number: number)
  end
end

Then(/^I should be on the litigator new claim page$/) do
  expect(@litigator_claim_form_page).to be_displayed
end

Then(/^I should be on the litigator new interim claim page$/) do
  expect(@interim_claim_form_page).to be_displayed
  @interim_claim_form_page.wait_until_continue_button_visible
end

When(/^I select the supplier number '(.*)'$/) do |number|
  @litigator_claim_form_page.select_supplier_number(number)
end

And(/^I select the litigator offence class '(.*)'$/) do |name|
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

And(/^I enter the fixed fee date$/) do
  @litigator_claim_form_page.fixed_fee_date.set_date "2016-01-01"
end

When(/^I add an expense '(.*?)'(?: with total '(.*?)')?(?: and VAT '(.*?)')?( with invalid date)?$/) do |name, total, vat, invalid_date|
  @claim_form_page.expenses.last.expense_type_dropdown.select name

  if name == 'Hotel accommodation'
    @claim_form_page.expenses.last.destination.set 'Liverpool'
  end
  @claim_form_page.expenses.last.reason_for_travel_dropdown.select 'View of crime scene'

  @claim_form_page.expenses.last.amount.set(total || '34.56')
  @claim_form_page.expenses.last.vat_amount.set(vat) if vat.present?

  if invalid_date.present?
    @claim_form_page.expenses.last.expense_date.set_invalid_date
  else
    @claim_form_page.expenses.last.expense_date.set_date '2016-01-02'
  end
end

And(/^I enter the date for the (\w+) expense '(.*?)'$/) do |ordinal, date|
  @claim_form_page.expenses.send(ordinal.to_sym).expense_date.set_date date
end

