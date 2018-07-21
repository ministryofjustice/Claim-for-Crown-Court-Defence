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
end

# FIXME: remove if unused
# When(/^I select '(.*)' as the instructed advocate$/) do |text|
#   @claim_form_page.select_advocate(text)
# end

When(/^I choose '(.*)' as the instructed advocate$/) do |text|
  @claim_form_page.find('label', text: text).click
end

When(/^I select the advocate offence class '(.*)'$/) do |offence_class|
  sleep 1
  @claim_form_page.select_offence_class(offence_class)
end

When(/I enter trial start and end dates$/) do
  using_wait_time 3 do
    @claim_form_page.trial_details.first_day_of_trial.set_date 9.days.ago.to_s
    @claim_form_page.trial_details.trial_concluded_on.set_date 2.days.ago.to_s
    @claim_form_page.trial_details.estimated_trial_length.set 5
    @claim_form_page.trial_details.actual_trial_length.set 8
  end
end

When(/^I search for the scheme 10 offence '(.*?)'$/) do |search_text|
  @claim_form_page.offence_search.set search_text
end

Then(/^I select the first search result$/) do
  sleep Capybara.default_max_wait_time
  @claim_form_page.offence_results.first.select_button(visible: false).trigger('click')
end

When(/^I add a basic fee with dates attended$/) do
  using_wait_time 6 do
    @claim_form_page.basic_fees.basic_fee.quantity.set "1"
    @claim_form_page.basic_fees.basic_fee.rate.set "3.45"
  end
end

When(/^I add a basic fee net amount$/) do
  using_wait_time 6 do
    @claim_form_page.basic_fees.basic_fee.total.set "3.45"
  end
end

When(/^I add a number of cases uplift fee with additional case numbers$/) do
  using_wait_time 6 do
    @claim_form_page.basic_fees.number_of_case_uplift_input.click()
    @claim_form_page.basic_fees.number_of_cases_uplift.quantity.set "1"
    @claim_form_page.basic_fees.number_of_cases_uplift.rate.set "200.00"
    @claim_form_page.basic_fees.number_of_cases_uplift.case_numbers.set "A20170001"
  end
end

When(/^I add a daily attendance fee with dates attended$/) do
  using_wait_time 6 do
    @claim_form_page.basic_fees.daily_attendance_fee_input.click()
    @claim_form_page.basic_fees.daily_attendance_fee_3_to_40.quantity.set "4"
    @claim_form_page.basic_fees.daily_attendance_fee_3_to_40.rate.set "45.77"
    @claim_form_page.basic_fees.daily_attendance_fee_3_to_40_dates.from.set_date "2016-01-04"
  end
end

When(/^I add a miscellaneous fee '(.*?)' with dates attended\s*(.*)?$/) do |name, date|
  date = date.present? ? date : "2016-01-02"
  @claim_form_page.add_misc_fee_if_required
  @claim_form_page.miscellaneous_fees.last.select_fee_type name
  @claim_form_page.miscellaneous_fees.last.quantity.set 1
  @claim_form_page.miscellaneous_fees.last.rate.set "34.56"
  @claim_form_page.miscellaneous_fees.last.add_dates.trigger "click"
  @claim_form_page.miscellaneous_fees.last.dates.from.set_date(date)
end

Then(/^I check the section heading to be "([^"]*)"$/) do |num|
  expect(@claim_form_page.miscellaneous_fees.last.numbered.text).to have_content(num)
end

When(/^I add a fixed fee '(.*?)'$/) do |name|
  @claim_form_page.add_fixed_fee_if_required
  @claim_form_page.fixed_fees.last.select_fee_type name
  @claim_form_page.fixed_fees.last.quantity.set 1
  @claim_form_page.fixed_fees.last.rate.set "12.34"
end

Then(/^I add a fixed fee '(.*?)' with case numbers$/) do |name|
  @claim_form_page.add_fixed_fee_if_required
  @claim_form_page.fixed_fees.last.select_fee_type name
  @claim_form_page.fixed_fees.last.quantity.set 1
  @claim_form_page.fixed_fees.last.rate.set "10.00"
  @claim_form_page.fixed_fees.last.case_numbers.set "T20170001"
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

Then(/^I should see retrial fields$/) do
  @claim_form_page.wait_for_retrial_details
  expect(@claim_form_page).to have_retrial_details
  expect(@claim_form_page.retrial_details).to be_visible
  expect(@claim_form_page.retrial_details).to be_all_there
end

Then(/^the last fixed fee case numbers section should (not )?be visible$/) do |negate|
  if negate
    expect(@claim_form_page.fixed_fees.last).to_not have_case_numbers_section
  else
    expect(@claim_form_page.fixed_fees.last).to have_case_numbers_section
  end
end

Then(/^I should see the advocate categories\s*'([^']*)'$/) do |categories|
  categories = categories.split(',')
  expect(@claim_form_page.advocate_category_radios).to be_visible
  expect(@claim_form_page.advocate_category_radios.radio_labels).to match_array(categories)
end

Then(/^I should see the (.*) applicable basic fees$/) do |scheme_text|
  additional_fees = scheme_text.match?('scheme 10') ? scheme_10_additional_fees : scheme_9_additional_fees
  expect(@claim_form_page.basic_fees.checklist_labels).to match_array(additional_fees)
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
