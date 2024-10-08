include WaitForAjax

Given(/^AGFS reform commenced on "([^"]*)"$/) do |agfs_reform_start_date|
  allow(Settings).to receive(:agfs_fee_reform_release_date).and_return Date.parse(agfs_reform_start_date)
end

Given(/^I am on the new claim page$/) do
  @claim_form_page.load
end

Then(/^I should be on the new claim page$/) do
  expect(@claim_form_page).to be_displayed
end

When(/^I select an advocate category of '(.*?)'$/) do |name|
  @claim_form_page.find('label', text: name).click
  wait_for_ajax
end

When(/^I choose '(.*)' as the trial advocate$/) do |text|
  @claim_form_page.find('label', text: text).click
end

When(/^I select the advocate offence class '(.*)'$/) do |offence_class|
  sleep 1
  @claim_form_page.select_offence_class(offence_class)
end

When(/I enter (.*?)(retrial|trial) start and end dates(?: with (\d+) day interval)?$/i) do |scheme_text, trial_type, interval|
  trial_start = Date.parse(scheme_date_for(scheme_text))
  trial_end = trial_start.next_day(7)

  using_wait_time 3 do
    @claim_form_page.trial_details.first_day_of_trial.set_date trial_start.strftime
    @claim_form_page.trial_details.trial_concluded_on.set_date trial_end.strftime
    @claim_form_page.trial_details.estimated_trial_length.set 5
    @claim_form_page.trial_details.actual_trial_length.set 8

    if trial_type.downcase.eql?('retrial')
      retrial_start = trial_end.next_day(interval.to_i)
      retrial_end = retrial_start.next_day(7)
      @claim_form_page.retrial_details.retrial_started_at.set_date retrial_start.strftime
      @claim_form_page.retrial_details.retrial_concluded_at.set_date retrial_end.strftime
      @claim_form_page.retrial_details.retrial_estimated_length.set 5
      @claim_form_page.retrial_details.retrial_actual_length.set 8
    end
  end
end

When(/I enter (.*?) main hearing date$/i) do |scheme_text|
  @claim_form_page.main_hearing_date.set_date Date.parse(main_hearing_date_for(scheme_text)).strftime
end

When(/I enter (.*?)(retrial|trial) long start and end dates(?: with (\d+) day interval)?$/i) do |scheme_text, trial_type, interval|
  trial_start = Date.parse(scheme_date_for(scheme_text))
  trial_end = trial_start.next_day(52)

  using_wait_time 3 do
    @claim_form_page.trial_details.first_day_of_trial.set_date trial_start.strftime
    @claim_form_page.trial_details.trial_concluded_on.set_date trial_end.strftime
    @claim_form_page.trial_details.estimated_trial_length.set 51
    @claim_form_page.trial_details.actual_trial_length.set 52

    if trial_type.downcase.eql?('retrial')
      retrial_start = trial_end.next_day(interval.to_i)
      retrial_end = retrial_start.next_day(52)
      @claim_form_page.retrial_details.retrial_started_at.set_date retrial_start.strftime
      @claim_form_page.retrial_details.retrial_concluded_at.set_date retrial_end.strftime
      @claim_form_page.retrial_details.retrial_estimated_length.set 51
      @claim_form_page.retrial_details.retrial_actual_length.set 52
    end
  end
end

When(/I choose (not )?to apply retrial reduction$/) do |negate|
  if negate
    @claim_form_page.retrial_details.retrial_reduction_no.click
  else
    @claim_form_page.retrial_details.retrial_reduction_yes.click
  end
end

Then(/^the basic fee net amount should be populated with '(\d+\.\d+)'$/) do |total|
  patiently do
    expect(@claim_form_page.basic_fees.basic_fee).to have_total
    expect(@claim_form_page.basic_fees.basic_fee.total.value).to eql total
  end
end

When(/^I select the '(.*?)' basic fee$/) do |label|
  @claim_form_page.basic_fees.check(label)
  wait_for_ajax
end

When("I enter {string} prosecution witnesses") do |quantity|
  @claim_form_page.basic_fees.prosecution_witnesses.quantity.set nil
  quantity.chars.each do |char|
    @claim_form_page.basic_fees.prosecution_witnesses.quantity.send_keys(char)
    wait_for_ajax
  end
end

Then("the prosecution witnesses net amount should be populated with {string}") do |amount|
  patiently do
    expect(@claim_form_page.basic_fees.prosecution_witnesses.total.value).to eql amount
  end
end

When("I enter {string} pages of prosecution evidence") do |quantity|
  @claim_form_page.basic_fees.pages_of_prosecution_evidence.quantity.set nil
  quantity.chars.each do |char|
    @claim_form_page.basic_fees.pages_of_prosecution_evidence.quantity.send_keys(char)
    wait_for_ajax
  end
end

Then("the pages of prosecution evidence net amount should be populated with {string}") do |amount|
  patiently do
    expect(@claim_form_page.basic_fees.pages_of_prosecution_evidence.total.value).to eql amount
  end
end

When('I click on misc fees helper text') do
  @misc_fee_page.misc_fees_id.click
end

Then("I should see the following miscellaneous fees listed:") do |table|
  expected_fees = table.raw.flatten

  expected_fees.each do |fee|
    expect(page).to have_content(fee)
  end
end

When(/^I add a calculated miscellaneous fee '(.*?)'(?: with quantity of '(.*?)')?(?: with dates attended\s*(.*))?$/) do |name, quantity, date|
  quantity = quantity.present? ? quantity : '1'
  patiently do
    @claim_form_page.add_misc_fee_if_required
  end
  @claim_form_page.miscellaneous_fees.last.select_fee_type name
  @claim_form_page.miscellaneous_fees.last.select_input.send_keys(:tab)
  wait_for_ajax
  @claim_form_page.miscellaneous_fees.last.quantity.set quantity
  @claim_form_page.miscellaneous_fees.last.quantity.send_keys(:tab)
  wait_for_ajax
  if date.present?
    @claim_form_page.miscellaneous_fees.last.add_dates.click
    @claim_form_page.miscellaneous_fees.last.dates.set_date(date)
  end
  wait_for_ajax
end

When(/^I add a govuk calculated miscellaneous fee '(.*?)'(?: with quantity of '(.*?)')?(?: with dates attended\s*(.*))?$/) do |name, quantity, date|
  quantity = quantity.present? ? quantity : '1'
  patiently do
    @claim_form_page.add_govuk_misc_fee_if_required
  end
  @claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete.choose_autocomplete_option(name)
  @claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete_input.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
  @claim_form_page.miscellaneous_fees.last.quantity.set quantity
  @claim_form_page.miscellaneous_fees.last.quantity.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
  if date.present?
    @claim_form_page.miscellaneous_fees.last.add_dates.click
    @claim_form_page.miscellaneous_fees.last.dates.set_date(date)
  end
  wait_for_debounce
  wait_for_ajax
end

Then("I add a govuk calculated miscellaneous fee {string} without a quantity") do |fee_name|
  quantity = quantity.present? ? quantity : '1'
  patiently do
    @claim_form_page.add_govuk_misc_fee_if_required
  end
  @claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete.choose_autocomplete_option(fee_name)
  @claim_form_page.miscellaneous_fees.last.govuk_fee_type_autocomplete_input.send_keys(:tab)

  sleep(2)
  wait_for_debounce
  wait_for_ajax
end

Then(/^I check the section heading to be "([^"]*)"$/) do |num|
  expect(@claim_form_page.miscellaneous_fees.last.numbered.text).to have_content(num)
end

Then(/^I select the '(.*?)' fixed fee( with case numbers)?$/) do |name, add_case_numbers|
  @claim_form_page.fixed_fees.check(name)
  wait_for_ajax
  @claim_form_page.fixed_fees.fee_block_for(name).case_numbers.set "T20170001" if add_case_numbers
  @claim_form_page.fixed_fees.set_quantity(name)
  wait_for_ajax
end

Then(/^I select the '(.*?)' basic fee(?: with quantity of (\d+))?( with case numbers)?$/) do |name, quantity, add_case_numbers|
  @claim_form_page.basic_fees.check(name)
  wait_for_ajax
  @claim_form_page.basic_fees.fee_block_for(name).case_numbers.set "T20170001" if add_case_numbers
  @claim_form_page.basic_fees.set_quantity(name, quantity || 1)
  wait_for_ajax
end

Then(/^I select the govuk field '(.*?)' basic fee(?: with quantity of (\d+))?( with case numbers)?$/) do |name, quantity, add_case_numbers|
  find('.govuk-checkboxes__item label', text: name).click
  wait_for_ajax
  @claim_form_page.basic_fees.fee_block_for(name).case_numbers.set "T20170001" if add_case_numbers
  @claim_form_page.basic_fees.set_quantity(name, quantity || 1)
  wait_for_ajax
end

When(/^I set the '(.*?)' fixed fee value to '(.*?)'$/) do |name, value|
  @claim_form_page.fixed_fees.fee_block_for(name).rate.set value
  wait_for_ajax
end

Given(/^There are other advocates in my provider$/) do
  FactoryBot.create(:external_user,
                     :advocate,
                     provider: @advocate.provider,
                     user: FactoryBot.create(:user, first_name: 'John', last_name: 'Doe'),
                     supplier_number: 'AC135')
  FactoryBot.create(:external_user,
                     :advocate,
                     provider: @advocate.provider,
                     user: FactoryBot.create(:user, first_name: 'Joe', last_name: 'Blow'),
                     supplier_number: 'XY455')
end

Given(/^6\+ advocates exist for my provider$/) do
  number_to_add = 6 - @advocate.provider.advocates.size
  number_to_add.times do |index|
    FactoryBot.create(:external_user, :advocate, provider: @advocate.provider)
  end
end

Then(/^I should see trial fields$/) do
  expect(@claim_form_page).to have_trial_details
  expect(@claim_form_page.trial_details).to be_visible
  expect(@claim_form_page.trial_details).to be_all_there
end

Then(/^I should see retrial fields$/) do
  expect(@claim_form_page).to have_retrial_details
  expect(@claim_form_page.retrial_details).to be_visible
  expect(@claim_form_page.retrial_details).to be_all_there
end

Then("I should see cracked trial fields") do
  expect(@claim_form_page).to have_cracked_trial_details
  expect(@claim_form_page.cracked_trial_details).to be_visible
  expect(@claim_form_page.cracked_trial_details).to be_all_there
end

Then(/^the last fixed fee case numbers section should (not )?be visible$/) do |negate|
  if negate
    expect(@claim_form_page.fixed_fees.last).to_not have_case_numbers_section
  else
    expect(@claim_form_page.fixed_fees.last).to have_case_numbers_section
  end
end

Given(/^I check the fixed fee "([^"]*)"$/) do |label|
  @claim_form_page.fixed_fees.check(label)
  wait_for_ajax
end

Given(/^I uncheck the fixed fee "([^"]*)"$/) do |label|
  @claim_form_page.fixed_fees.uncheck(label)
  wait_for_ajax
end

Then(/^the fixed fee '(.*)' entry should be unchecked$/) do |label|
  checkbox = @claim_form_page.fixed_fees.checklist_item_for(label).checkbox
  expect(checkbox).to_not be_checked
end

Then(/^the fixed fee checkboxes should consist of \s*'([^']*)'$/) do |fee_type_descriptions|
  fee_type_descriptions = CSV.parse(fee_type_descriptions).flatten
  expect(@claim_form_page.fixed_fees.checklist_labels).to match_array(fee_type_descriptions)
end

Then(/^the '(.*?)' fee '(.*?)' should have a rate of '(\d+\.\d+)'(?: and a hint of '(.*?)')?$/) do |fee_type, description, rate, hint|
  fee_block = @claim_form_page.fee_block_for("#{fee_type}_fees", description)
  expect(fee_block.rate.value).to eql rate
  expect(fee_block.quantity_hint).to have_text(hint) if hint.present?
  expect(fee_block.calc_help_text).to be_visible
end

# Alternative data table step for the above
Then(/^the following fee details should exist:$/) do |table|
  table.hashes.each do |row|
    fee_block = @claim_form_page.fee_block_for("#{row['section']}_fees", row['fee_description'])

    expect(fee_block.rate.value).to eql row['rate']
    expect(fee_block.quantity_hint).to have_text(row['hint']) if row.keys.include?('hint')
    expect(fee_block).to have_calc_help_text if row.keys.include?('help') && row['help'].eql?('true')
    expect(fee_block).to_not have_calc_help_text if row.keys.include?('help') && !row['help'].eql?('true')
  end
end

Then(/^the following govuk fee details should exist:$/) do |table|
  table.hashes.each do |row|
    fee_block = @claim_form_page.govuk_fee_block_for("#{row['section']}_fees", row['fee_description'])

    expect(fee_block.rate.value).to eql row['rate']
    expect(fee_block.quantity_hint).to have_text(row['hint']) if row.keys.include?('hint')
    expect(fee_block).to have_calc_help_text if row.keys.include?('help') && row['help'].eql?('true')
    expect(fee_block).to_not have_calc_help_text if row.keys.include?('help') && !row['help'].eql?('true')
  end
end

Then(/^the fixed fee '(.*?)' should have a rate of '(\d+\.\d+)'(?: and a hint of '(.*?)')?$/) do |fee, rate, hint|
  fee_block = @claim_form_page.fixed_fees.fee_block_for(fee)
  wait_for_ajax
  expect(fee_block.rate.value).to eql rate
  expect(fee_block.quantity_hint.text).to eql hint if hint.present?
end

Then(/^the last '(.*?)' fee rate should be populated with '(\d+\.\d+)'$/) do |fee_type, rate|
  expect(@claim_form_page.send("#{fee_type}_fees").last).to have_rate
  expect(@claim_form_page.send("#{fee_type}_fees").last.rate.value).to eql rate
end

Then(/^the last fixed fee rate should be in the calculator error state/) do
  expect(@claim_form_page.fixed_fees.last).to have_rate
  expect(@claim_form_page.fixed_fees.last.rate.value).to be_empty
  expect(@claim_form_page.fixed_fees.last.text).to match /The calculated rate is unavailable, enter manually/
end

Then(/^the '(.*?)' fixed fee rate should be in the calculator error state/) do |name|
  fee_block = @claim_form_page.fixed_fees.fee_block_for(name)
  expect(fee_block).to have_rate
  expect(fee_block.rate.value).to be_empty
  expect(fee_block.text).to match /The calculated rate is unavailable, enter manually/
end

Then("I click last remove link") do
  @claim_form_page.find_all('.remove_fields').last.click
end

Then("I amend the fixed fee {string} to have a quantity of {string}") do |fee_type, quantity|
  fixed_fee = @claim_form_page.fixed_fees.fee_block_for(fee_type)
  fixed_fee.quantity.set(quantity)
  fixed_fee.quantity.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
end

Then("I amend the miscellaneous fee {string} to have a quantity of {string}") do |fee_type, quantity|
  misc_fee = @claim_form_page.fee_block_for(:miscellaneous_fees, fee_type)
  misc_fee.quantity.set(quantity)
  misc_fee.quantity.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
end

Then("I amend the govuk miscellaneous fee {string} to have a quantity of {string}") do |fee_type, quantity|
  misc_fee = @claim_form_page.govuk_fee_block_for(:miscellaneous_fees, fee_type)
  misc_fee.quantity.set(quantity)
  misc_fee.quantity.send_keys(:tab)
  wait_for_debounce
  wait_for_ajax
end

Then(/^I should see the advocate categories\s*'([^']*)'$/) do |categories|
  categories = categories.split(',')
  expect(@claim_form_page.advocate_category_radios).to be_visible
  expect(@claim_form_page.advocate_category_radios.radio_labels).to match_array(categories)
end

Then('I should see the scheme {int} applicable basic fees') do |scheme_no|
  additional_fees = scheme_no.eql?(9) ? scheme_9_additional_fees : scheme_10_additional_fees
  expect(@claim_form_page.basic_fees.checklist_labels).to match_array(additional_fees)
end

Then('I should see the scheme {int} applicable basic fees based on the govuk checkbox group') do |scheme_no|
  additional_fees = scheme_no.eql?(9) ? scheme_9_additional_fees : scheme_10_additional_fees
  expect(@claim_form_page.basic_fees.basic_fees_checkboxes.checklist_labels).to match_array(additional_fees)
end

Then(/^the basic fee should have its price_calculated value set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  basic_fee = claim.basic_fees.find_by(fee_type_id: Fee::BaseFeeType.find_by(unique_code: 'BABAF').id)
  expect(basic_fee.price_calculated).to eql true
end

Then(/^all the fixed fees should have their price_calculated values set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  expect(claim.fixed_fees.pluck(:price_calculated).all?).to eql true
end

Then(/^the following fees should have their price_calculated set to true:\s*'([^']*)'$/) do |unique_codes|
  unique_codes = unique_codes.split(',')
  fees = Claim::BaseClaim.
          find(@claim_form_page.claim_id).
          fees.
          where(fee_type_id: Fee::BaseFeeType.where(unique_code: unique_codes))
  expect(fees.map(&:price_calculated).all?).to eql(true), "expected all to be true:\n got: #{fees.each_with_object({}) { |f, memo| memo[f.fee_type.unique_code.to_sym] = f.price_calculated }}"
end

Then(/^all the misc fees should have their price_calculated values set to true$/) do
  claim = Claim::BaseClaim.find(@claim_form_page.claim_id)
  expect(claim.misc_fees.pluck(:price_calculated).all?).to eql true
end

def scheme_9_additional_fees
  [
    'Daily attendance fee (3 to 40)',
    'Daily attendance fee (41 to 50)',
    'Daily attendance fee (51+)',
    'Standard appearance fee',
    'Plea and trial preparation hearing',
    'Conferences and views',
    'Number of defendants uplift',
    'Number of cases uplift'
  ].freeze
end

def scheme_10_additional_fees
  [
    'Daily attendance fee (2+)',
    'Standard appearance fee',
    'Plea and trial preparation hearing',
    'Conferences and views',
    'Number of defendants uplift',
    'Number of cases uplift'
  ].freeze
end

