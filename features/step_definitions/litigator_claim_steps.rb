And(/^My provider has supplier numbers$/) do
  [['1A222Z', 'SW1H 9AJ'], ['2B333Z', nil]].each do |number, postcode|
    @litigator.provider.lgfs_supplier_numbers << SupplierNumber.new(supplier_number: number, postcode: postcode)
  end
end

And('6+ supplier numbers exist for my provider')do
  number_to_add = 6 - @litigator.provider.lgfs_supplier_numbers.size
  number_to_add.times do |index|
    @litigator.provider.lgfs_supplier_numbers << SupplierNumber.new(supplier_number: additional_supplier_numbers[index])
  end
end

Then(/^I should be on the litigator new claim page$/) do
  expect(@litigator_claim_form_page).to be_displayed
end

And(/^I select the litigator offence class '(.*)'$/) do |name|
  @litigator_claim_form_page.select_offence_class(name)
end

And(/^I fill '(.*)' as the fixed fee total$/) do |total|
  @litigator_claim_form_page.fixed_fee_total.set total
end

And(/^I fill '(.*)' as the graduated fee total$/) do |total|
  @litigator_claim_form_page.graduated_fee_total.set total
end

Then(/^I fill '(\d+)' as the ppe total$/) do |total|
  @litigator_claim_form_page.ppe_total.set total
end

Then(/^I fill '(\d+)' as the actual trial length$/) do |total|
  @litigator_claim_form_page.actual_trial_length.set total
end

And(/^I fill '(.*)' as the warrant fee total$/) do |total|
  @litigator_claim_form_page.warrant_fee_total.set total
end

And(/^I enter the case concluded date\s*(.*?)$/) do |date|
  date = date.present? ? date : "2016-01-01"
  @litigator_claim_form_page.case_concluded_date.set_date date
end

And(/^I add a litigator miscellaneous fee '(.*)'$/) do |name|
  @litigator_claim_form_page.add_misc_fee_if_required
  @claim_form_page.all('label', text: name).last.click
  @litigator_claim_form_page.miscellaneous_fees.last.amount.set "135.78"
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

And(/^I fill '(.*)' as the graduated fee date$/) do |date|
  @litigator_claim_form_page.graduated_fee_date.set_date date
end

And(/^I fill '(.*)' as the warrant fee issued date$/) do |date|
  @litigator_claim_form_page.warrant_fee_issued_date.set_date date
end

And(/^I fill '(.*)' as the warrant fee executed date$/) do |date|
  @litigator_claim_form_page.warrant_fee_executed_date.set_date date
end

Then(/^I select an expense type "([^"]*)"$/) do |name|
  @claim_form_page.expenses.last.expense_type_dropdown.select name
end

Then(/^I select a mileage rate of '(\d+)p per mile'$/) do |arg1|
  @claim_form_page.expenses.last.mileage_20.click
end

Then(/^I select a travel reason "([^"]*)"$/) do |name|
  @claim_form_page.expenses.last.reason_for_travel_dropdown.select name
end

Then(/^I add an other reason of "([^"]*)"$/) do |reason_text|
  @claim_form_page.expenses.last.other_reason_input.set reason_text
end

Then(/^I add an expense location$/) do
  @claim_form_page.expenses.last.destination.set 'Liverpool'
end

Then(/^I add an expense distance of "([^"]*)"$/) do |number|
  @claim_form_page.expenses.last.distance.set number
end

Then(/^I add an expense date for scheme (\d+)$/) do |scheme|
  date = scheme.match?('10') ? Settings.agfs_fee_reform_release_date.strftime : "2016-01-02"
  @claim_form_page.expenses.last.expense_date.set_date date
end

Then(/^I should see a destination label of "([^"]*)"$/) do |label_text|
  expect(@claim_form_page.expenses.last.destination_label.text).to eq(label_text)
end

Then(/^I add an expense net amount for "([^"]*)"$/) do |net_amount|
  @claim_form_page.expenses.last.amount.set(net_amount || '34.56')
end

Then(/^I add an expense vat amount for "([^"]*)"$/) do |vat_amount|
  @claim_form_page.expenses.last.vat_amount.set(vat_amount || '6.91')
end

Then(/^I add an expense date as invalid$/) do
  @claim_form_page.expenses.last.expense_date.set_invalid_date
end

And(/^I enter the date for the (\w+) expense '(.*?)'$/) do |ordinal, date|
  @claim_form_page.expenses.send(ordinal.to_sym).expense_date.set_date date
end

def additional_supplier_numbers
  %w[1A833H 1A832G 1A831F 1A830E 1A829D 1A828C 1A827B 1A826A 1A825Z 1A824Y 1A823X 1A822W 1A821V 1A820U]
end

Then(/^I should see the additional info area$/) do
  expect(@claim_form_page.additional_information_expenses).to be_visible
end
