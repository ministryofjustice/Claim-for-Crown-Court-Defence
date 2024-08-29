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

And(/^I fill '(.*)' as the fixed fee date$/) do |date|
  @litigator_claim_form_page.fixed_fee.date.set_date date
end

And(/^I fill '(\d+)' as the fixed fee quantity$/) do |quantity|
  @litigator_claim_form_page.fixed_fee.quantity.set nil
  @litigator_claim_form_page.fixed_fee.quantity.send_keys("#{quantity}")
  wait_for_ajax
end

Then(/I should see fixed fee type '(.*)'$/) do |description|
  expect(@litigator_claim_form_page.fixed_fee).to have_text(description)
end

Then(/^the fixed fee rate should be populated with '(\d+\.\d+)'$/) do |rate|
  expect(@litigator_claim_form_page.fixed_fee).to have_rate
  expect(@litigator_claim_form_page.fixed_fee.rate.value).to eql rate
end

Then(/^the graduated fee amount should be populated with '(\d+\.\d+)'$/) do |amount|
  patiently do
    expect(@litigator_claim_form_page.graduated_fee).to have_amount
    expect(@litigator_claim_form_page.graduated_fee.amount.value).to eql amount
  end
end

Then(/I should see fixed fee total '£?(\d+\.\d+)'$/) do |total_text|
  patiently do
    expect(@litigator_claim_form_page.fixed_fee).to have_total
    expect(@litigator_claim_form_page.fixed_fee.total.text).to match(total_text)
  end
end

# note this covers LGFS grad, interim and transfer quantity fields
# whose quantity field represents PPE.
Then("I enter {string} in the PPE total graduated fee field") do |total|
  @litigator_claim_form_page.ppe_total.set nil
  total.chars.each do |char|
    @litigator_claim_form_page.ppe_total.send_keys(char)
    wait_for_ajax
  end
end

Then("I fill {string} as the actual trial length") do |length|
  @litigator_claim_form_page.actual_trial_length.set nil
  length.chars.each do |char|
    @litigator_claim_form_page.actual_trial_length.send_keys(char)
    wait_for_ajax
  end
end

And(/^I enter the case concluded date\s*(.*?)$/) do |date|
  date = date.present? ? date : "2016-04-01"
  @litigator_claim_form_page.case_concluded_date.set_date date
end

And(/^I add a litigator miscellaneous fee '(.*)'$/) do |name|
  @litigator_claim_form_page.add_govuk_misc_fee_if_required
  @litigator_claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete.choose_autocomplete_option(name)
  @litigator_claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete_input.send_keys(:tab)
  @litigator_claim_form_page.miscellaneous_fees.last.quantity.set "1"
  @litigator_claim_form_page.miscellaneous_fees.last.rate.set "135.78"
end

And(/^I should see a calculated fee net amount of '(.*)'$/) do |amount|
  expect(@litigator_claim_form_page.miscellaneous_fees.last.net_amount.text).to eq(amount)
end

And(/^I should see a total calculated miscellaneous fees amount of '(.*)'$/) do |amount|
  expect(@litigator_claim_form_page.sidebar_misc_amount.text).to eq(amount)
end

When(/^I add a litigator calculated miscellaneous fee '(.*?)'(?: with quantity of '(.*?)')$/) do |name, quantity|
  quantity = quantity.present? ? quantity : '1'
  @litigator_claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete.choose_autocomplete_option(name)
  @litigator_claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete_input.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
  @litigator_claim_form_page.miscellaneous_fees.last.quantity.set quantity
  @litigator_claim_form_page.miscellaneous_fees.last.quantity.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
end

Then(/^I should see a rate of '(.*?)'$/) do |rate|
  expect(@litigator_claim_form_page.miscellaneous_fees.last.rate.value).to eq(rate)
end

Then(/^the first miscellaneous fee should have fee types\s*'([^']*)'$/) do |descriptions|
  descriptions = descriptions.split(',').map(&:strip)
  expect(@litigator_claim_form_page.miscellaneous_fees.first.fee_type).to be_visible
  expect(@litigator_claim_form_page.miscellaneous_fees.first.fee_type.radio_labels).to match_array(descriptions)
end

And(/^I add (?:a|another) disbursement '(.*)' with net amount '(.*)' and vat amount '(.*)'$/) do |name, net_amount, vat_amount|
  @litigator_claim_form_page.add_disbursement_if_required
  @litigator_claim_form_page.disbursements.last.disbursement_select.choose_autocomplete_option(name)
  @litigator_claim_form_page.disbursements.last.net_amount.set net_amount
  @litigator_claim_form_page.disbursements.last.vat_amount.set vat_amount
end

And(/^I fill '(.*)' as the graduated fee date$/) do |date|
  @litigator_claim_form_page.graduated_fee_date.set_date date
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

Then('I add an expense location of {string}') do |string|
  @claim_form_page.expenses.last.destination.set string
end

Then(/^I add an expense location$/) do
  @claim_form_page.expenses.last.destination.set 'Liverpool'
end

Then(/^I add an expense distance of "([^"]*)"$/) do |number|
  @claim_form_page.expenses.last.distance.set number
end

Then(/^I add an expense date for (.*?)$/) do |scheme_text|
  date = scheme_date_for(scheme_text)
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

Then(/^the graduated fee should have its price_calculated value set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  expect(claim.graduated_fee.price_calculated).to eql true
end

Then(/^the fixed fee should have its price_calculated value set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  expect(claim.fixed_fee.price_calculated).to eql true
end
