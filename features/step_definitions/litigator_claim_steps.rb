And(/^My provider has supplier numbers$/) do
  %w(1A222Z 2B333Z).each do |number|
    @litigator.provider.lgfs_supplier_numbers << SupplierNumber.new(supplier_number: number)
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

def additional_supplier_numbers
  %w[1A833H 1A832G 1A831F 1A830E 1A829D 1A828C 1A827B 1A826A 1A825Z 1A824Y 1A823X 1A822W 1A821V 1A820U]
end
