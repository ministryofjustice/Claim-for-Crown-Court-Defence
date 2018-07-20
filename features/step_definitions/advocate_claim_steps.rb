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

When(/^I select '(.*)' as the instructed advocate$/) do |text|
  @claim_form_page.select_advocate(text)
end

When(/^I choose '(.*)' as the instructed advocate$/) do |text|
  @claim_form_page.find('label', text: text).click
end

When(/^I select the court '(.*?)'$/) do |name|
  @claim_form_page.select_court(name)
end

When(/^I select a case type of '(.*?)'$/) do |name|
  @claim_form_page.select_case_type name
end

When(/^I enter a case number of '(.*?)'$/) do |number|
  @claim_form_page.case_number.set number
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

When(/^I enter (.*?)defendant, representation order and MAAT reference$/) do |scheme_text|
    date = scheme_text.match?('scheme 10') || scheme_text.match?('post agfs reform') ? Settings.agfs_fee_reform_release_date.strftime : "2016-01-01"
    using_wait_time(6) do
      @claim_form_page.wait_for_defendants
      @claim_form_page.defendants.first.first_name.set "Bob"
      @claim_form_page.defendants.first.last_name.set "Billiards"
      @claim_form_page.defendants.first.dob.set_date "1955-01-01"
      @claim_form_page.defendants.last.representation_orders.first.date.set_date date
      @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
    end
end

When(/^I save as draft$/) do
  # @claim_form_page.save_to_drafts.trigger('click')
  @claim_form_page.save_to_drafts.click
end

When(/^I add another (.*?)defendant, representation order and MAAT reference$/) do |scheme_text|
  date = scheme_text.match?('scheme 10') || scheme_text.match?('post agfs reform') ? Settings.agfs_fee_reform_release_date.strftime : "2016-01-01"
  using_wait_time 6 do
    @claim_form_page.add_another_defendant.click
    wait_for_ajax
    @claim_form_page.defendants.last.first_name.set "Ned"
    @claim_form_page.defendants.last.last_name.set "Kelly"
    @claim_form_page.defendants.last.dob.set_date "1912-12-12"
    @claim_form_page.defendants.last.add_another_representation_order.click
    sleep 1
    # do it again if the first click failed
    @claim_form_page.defendants.last.add_another_representation_order.click if @claim_form_page.defendants.last.representation_orders.first.nil?
    @claim_form_page.defendants.last.representation_orders.first.date.set_date date
    @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
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
    @claim_form_page.initial_fees.basic_fee.quantity.set "1"
    @claim_form_page.initial_fees.basic_fee.rate.set "3.45"
  end
end

When(/^I add a basic fee net amount$/) do
  using_wait_time 6 do
    @claim_form_page.initial_fees.basic_fee.total.set "3.45"
  end
end

When(/^I add a number of cases uplift fee with additional case numbers$/) do
  using_wait_time 6 do
    @claim_form_page.initial_fees.number_of_case_uplift_input.click()
    @claim_form_page.initial_fees.number_of_cases_uplift.quantity.set "1"
    @claim_form_page.initial_fees.number_of_cases_uplift.rate.set "200.00"
    @claim_form_page.initial_fees.number_of_cases_uplift.case_numbers.set "A20170001"
  end
end

When(/^I add a daily attendance fee with dates attended$/) do
  using_wait_time 6 do
    @claim_form_page.initial_fees.daily_attendance_fee_input.click()
    @claim_form_page.initial_fees.daily_attendance_fee_3_to_40.quantity.set "4"
    @claim_form_page.initial_fees.daily_attendance_fee_3_to_40.rate.set "45.77"
    @claim_form_page.initial_fees.daily_attendance_fee_3_to_40_dates.from.set_date "2016-01-04"
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

When(/^I upload (\d+) documents?$/) do |count|
  @document_count = count.to_i
  @claim_form_page.attach_evidence(@document_count)
end

When(/^I check the boxes for the uploaded documents$/) do
  @claim_form_page.check_evidence_checklist(@document_count)
end

When(/^I check the evidence boxes for\s+'([^']*)'$/) do |labels|
  labels = labels.split(',')
  labels.each do |label|
    @claim_form_page.evidence_checklist.check(label)
  end
end

Then(/^I should see evidence boxes for\s+'([^']*)'$/) do |labels|
  labels = labels.split(',')
  expect(@claim_form_page.evidence_checklist).to be_visible
  expect(@claim_form_page.evidence_checklist.labels).to match_array(labels)
end

# NOTE: can't use have_items because, at least, LAC1 check box may not have a label/be-hidden
Then(/^I should see (\d+)\s*evidence check boxes$/) do |count|
  expect(@claim_form_page.evidence_checklist).to be_visible
  expect(@claim_form_page.evidence_checklist.labels.count).to eql(count.to_i) if count.present?
end

When(/^I add some additional information$/) do
  @claim_form_page.additional_information.set "Bish bosh bash"
end

When(/^I click "Continue" in the claim form$/) do
  sleep 3
  @claim_form_page.continue_button.click
  wait_for_ajax
end

When(/^I click Submit to LAA$/) do
  allow(Aws::SNS::Client).to receive(:new).and_return Aws::SNS::Client.new(region: 'eu_west_1', stub_responses: true)
  @claim_form_page.submit_to_laa.trigger "click"
end

Then(/^I should be on the check your claim page$/) do
  @claim_summary_page.wait_for_continue # Allow summary page to appear
  expect(@claim_summary_page).to be_displayed
end

When(/^I click "Continue"$/) do
  @claim_summary_page.continue.click
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
  expect(@claim_form_page.initial_fees.additional_fee_labels).to match_array(additional_fees)
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
