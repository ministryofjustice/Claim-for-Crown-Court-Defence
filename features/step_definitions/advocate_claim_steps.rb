
include WaitForAjax

Given(/^I am on the new claim page$/) do
  @claim_form_page.load
end

Then(/^I should be on the new claim page$/) do
  expect(@claim_form_page).to be_displayed
end

When(/^I select an advocate category of '(.*?)'$/) do |name|
  @claim_form_page.claim_advocate_category_junior_alone.click
end

When(/^I select an advocate$/) do
  @claim_form_page.select_advocate "Doe, John: AC135"
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

When(/^I select an offence category$/) do
  @claim_form_page.select_offence_category "Murder"
end

When(/I enter trial start and end dates$/) do
  using_wait_time 3 do
    @claim_form_page.trial_details.first_day_of_trial.set_date 9.days.ago.to_s
    @claim_form_page.trial_details.trial_concluded_on.set_date 2.days.ago.to_s
    @claim_form_page.trial_details.actual_trial_length.set 8
  end
end

When(/^I enter defendant, representation order and MAAT reference$/) do
  @claim_form_page.defendants.first.first_name.set "Bob"
  @claim_form_page.defendants.first.last_name.set "Billiards"
  @claim_form_page.defendants.first.dob.set_date "1955-01-01"
  @claim_form_page.defendants.last.representation_orders.first.date.set_date "2016-01-01"
  @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
end

When(/^I save as draft$/) do
  @claim_form_page.save_to_drafts.trigger('click')
end

When(/^I add another defendant, representation order and MAAT reference$/) do
  using_wait_time 3 do
    @claim_form_page.add_another_defendant.click
    wait_for_ajax
    @claim_form_page.defendants.last.first_name.set "Ned"
    @claim_form_page.defendants.last.last_name.set "Kelly"
    @claim_form_page.defendants.last.dob.set_date "1912-12-12"
    @claim_form_page.defendants.last.add_another_representation_order.click
    sleep 2
    @claim_form_page.defendants.last.representation_orders.first.date.set_date "2016-01-01"
    @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
  end
end

When(/^I add a basic fee with dates attended$/) do
  wait_for_ajax
  @claim_form_page.initial_fees.basic_fee.quantity.set "1"
  @claim_form_page.initial_fees.basic_fee.rate.set "3.45"
  # @claim_form_page.initial_fees.basic_fee.add_dates.click
  # @claim_form_page.initial_fees.basic_fee_dates.from.set_date "2016-01-02"
  # @claim_form_page.initial_fees.basic_fee_dates.to.set_date "2016-01-03"
end

When(/^I add a daily attendance fee with dates attended$/) do
  @claim_form_page.initial_fees.daily_attendance_fee_3_to_40.quantity.set "4"
  @claim_form_page.initial_fees.daily_attendance_fee_3_to_40.rate.set "45.77"
  @claim_form_page.initial_fees.daily_attendance_fee_3_to_40.add_dates.click
  @claim_form_page.initial_fees.daily_attendance_fee_3_to_40_dates.from.set_date "2016-01-04"
  @claim_form_page.initial_fees.daily_attendance_fee_3_to_40_dates.to.set_date "2016-01-05"
end

When(/^I add a miscellaneous fee '(.*?)' with dates attended$/) do |name|
  @claim_form_page.add_misc_fee_if_required
  @claim_form_page.miscellaneous_fees.last.select_fee_type name
  @claim_form_page.miscellaneous_fees.last.quantity.set 1
  @claim_form_page.miscellaneous_fees.last.rate.set "34.56"
  @claim_form_page.miscellaneous_fees.last.add_dates.trigger "click"
  @claim_form_page.miscellaneous_fees.last.dates.from.set_date "2016-01-02"
  @claim_form_page.miscellaneous_fees.last.dates.to.set_date "2016-01-03"
end

When(/^I add a fixed fee '(.*?)'$/) do |name|
  @claim_form_page.fixed_fees.last.select_fee_type name
  @claim_form_page.fixed_fees.last.quantity.set 1
  @claim_form_page.fixed_fees.last.rate.set "12.34"
end

When(/^I upload (\d+) documents?$/) do |count|
  @document_count = count.to_i
  @claim_form_page.attach_evidence(@document_count)
end

When(/^I check the boxes for the uploaded documents$/) do
  @claim_form_page.check_evidence_checklist(@document_count)
end

When(/^I add some additional information$/) do
  @claim_form_page.additional_information.set "Bish bosh bash"
end

When(/^I click "Continue" in the claim form$/) do
  @claim_form_page.continue.click
  wait_for_ajax
end

When(/^I click Submit to LAA$/) do
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
  FactoryGirl.create(:external_user,
                     :advocate,
                     provider: @advocate.provider,
                     user: FactoryGirl.create(:user, first_name: 'John', last_name: 'Doe'),
                     supplier_number: 'AC135')
  FactoryGirl.create(:external_user,
                     :advocate,
                     provider: @advocate.provider,
                     user: FactoryGirl.create(:user, first_name: 'Joe', last_name: 'Blow'),
                     supplier_number: 'XY455')
end