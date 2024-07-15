Given(/^I visit "(.*?)"$/) do |path|
  visit path
end

When(/^I save and open page$/) do
  save_and_open_page
end

When(/^I save and open screenshot$/) do
  screenshot_and_open_image
end

Given(/^I am on the 'Your claims' page$/) do
  @external_user_home_page.load
end

Given(/^I click 'Start a claim'$/) do
  @external_user_home_page.start_a_claim.click
end

Given(/^I click 'Your claims' link$/) do
  @external_user_home_page.your_claims_link.click
end

Then(/^I should (see|not see) ['"](.*)['"]$/) do |visibility, text|
  if (visibility == 'see')
    expect(page).to have_content(text)
  else
    expect(page).not_to have_content(text)
  end
end

Then(/^I should see a supplier number select list$/) do
  expect(@claim_form_page).to have_auto_lgfs_supplier_number
end

Then(/^I should see (\d+) supplier number radios$/) do |number|
  expect(@claim_form_page.lgfs_supplier_number_radios).to be_visible
  expect(@claim_form_page.lgfs_supplier_number_radios).to have_supplier_numbers(count: number)
end

When(/^I choose the supplier number '(.*)'$/) do |text|
  @claim_form_page.find('label', text: text).click
end

When(/^I select the supplier number '(.*)'$/) do |number|
  @claim_form_page.select_supplier_number(number)
end

And (/^I should see the London fee radios$/) do
  expect(@claim_form_page.london_fees).to be_visible
end

And (/^I select '(.*)' to London fees$/) do |option|
  @claim_form_page.london_fees.yes.click if option.downcase == 'yes'
  @claim_form_page.london_fees.no.click if option.downcase == 'no'
end

When(/^I select the offence category '(.*?)'$/) do |offence_cat|
  @claim_form_page.auto_offence.choose_autocomplete_option(offence_cat)
  wait_for_ajax
end

And('I sleep for {int} seconds') do |seconds|
  sleep seconds.to_i
end

Given(/^I am later on the Your claims page$/) do
  @external_user_home_page.load
end

When(/I click the claim '(.*?)'$/) do |case_number|
  @external_user_home_page.claim_for(case_number).case_number.click
end

When(/I click the first '(.*?)' link$/) do |text|
  expect(page).to have_link(text)
  click_link(text, match: :first)
end

When(/I click the link '(.*?)'$/) do |text|
  expect(page).to have_link(text)
  click_link(text)
end

When(/I click the button '(.*?)'$/) do |text|
  expect(page).to have_button(text)
  click_button(text)
end

When(/I edit this claim/) do
  @external_user_claim_show_page.edit_this_claim.click
end

Then(/^I should be on the claim confirmation page$/) do
  patiently do
    expect(@confirmation_page).to be_displayed
  end
end

When(/^I click View your claims$/) do
  @confirmation_page.wait_until_view_your_claims_visible
  patiently do
    @confirmation_page.view_your_claims.click
  end
end

Then(/^My new claim should be displayed$/) do
  expect(@external_user_home_page).to be_displayed
end

Then(/^I should be on the your claims page$/) do
  patiently do
    expect(@external_user_home_page).to be_displayed
  end
end

Then(/^Claim '(.*?)' should be listed with a status of '(.*?)'(?: and a claimed amount of '(.*?)')?$/) do |case_number, status, claimed|
  my_claim = @external_user_home_page.claim_for(case_number)
  expect(my_claim).not_to be_nil
  expect(my_claim.state.text).to eq(status)
  expect(my_claim.claimed.text).to eq(claimed) if claimed
end

Then(/^I should see the error '(.*?)'$/) do |error_message|
  within('div.error-summary') do
    expect(page).to have_content(error_message)
  end
end

And(/^I should see in the sidebar total '(.*?)'$/) do |total|
  within('div.totals-summary') do
    expect(page.find('dd.total-grandTotal')).to have_content(total)
  end
end

And(/^I should see in the sidebar vat total '(.*?)'$/) do |total|
  within('div.totals-summary') do
    expect(page.find('dd.total-vat')).to have_content(total)
  end
end

Then(/^I should see a page title "([^"]*)"$/) do |page_title|
  expect(page.title).to have_content(page_title)
end

And(/^I should be in the '(.*?)' form page$/) do |page_heading|
  within('#claim-form') do
    expect(page.first('h2')).to have_content(page_heading)
  end
  wait_for_ajax
end

And(/^I should see the field '(.*?)' with value '(.*?)' in '(.*?)'$/) do |field, value, section|
  within(page.find(:css, 'div.app-summary-section', text: section)) do
    expect(page).to have_content(value)
  end
end

Given("the current date is {string}") do |string|
  travel_to string.to_date
end

Given("I refresh the page") do
  page.driver.browser.navigate.refresh
end

# Record modes can be: all, none, new_episodes or once. Default is 'none'.
# When creating new tests that calls new endpoints, you will need to record the cassette.
# NOTE: see the README section 'Recording new VCR cassettes' for assistance
# NOTE: Never commit code that would result in VCR attempting to record a cassette
#       i.e. either cassette must exist, or you explicitly call "and record 'none'"
#
And(/^I insert the VCR cassette '(.*?)'(?: and record '(.*?)')?$/) do |name, record|
  record_mode = ENV['FEE_CALC_VCR_MODE']&.to_sym if fee_calc_vcr_tag?
  record_mode ||= (record || 'once').to_sym
  VCR.eject_cassette if VCR.current_cassette
  if fee_calc_vcr_tag?
    VCR.insert_cassette(name, record: record_mode, :match_requests_on => [:method, :path_query_matcher])
  else
    VCR.insert_cassette(name, record: record_mode)
  end
end

And(/^I eject the VCR cassette$/) do
  VCR.eject_cassette
end

And('I fill in {string} with {string}') do |label, text|
  fill_in label, with: text
end

And('the text field {string} should be filled with {string}') do |label, value|
  actual_value = find_field(label).value
  expect(actual_value).to eql(value)
end

Then('I should see link {string}') do |string|
  expect(page).to have_link(string)
end

Then('I should see button {string}') do |string|
  expect(page).to have_button(string)
end

When('I go back') do
  page.go_back
end

Given('popups are enabled') do
  overwrite_constant :ENABLED, false, Rack::NoPopups
end
