Given(/^I visit "(.*?)"$/) do |path|
  visit path
end

When(/^show me the page$/) do
  save_and_open_page
end

When(/^I start a claim/) do
  find('.primary-nav-bar').click_link('Start a claim')
end

And(/^I select the fee scheme '(.*)'$/) do |fee_scheme|
  method_name = fee_scheme.downcase.gsub(' ', '_').to_sym
  @fee_scheme_selector.send(method_name).click
  @fee_scheme_selector.continue.click
end

Given(/^I am on the 'Your claims' page$/) do
  @external_user_home_page.load
end

Given(/^I click 'Start a claim'$/) do
  @external_user_home_page.start_a_claim.click
end

Then(/^I should see '(.*?)'$/) do |content|
  expect(page).to have_content(content)
end

Given(/^I am later on the Your claims page$/) do
  @external_user_home_page.load
end

When(/I click the claim '(.*?)'$/) do |case_number|
  @external_user_home_page.claim_for(case_number).case_number.click
end

When(/I edit this claim/) do
  @external_user_claim_show_page.edit_this_claim.click
end

Then(/^I should be on the certification page$/) do
  expect(@certification_page).to be_displayed
end

When(/^I check “I attended the main hearing”$/) do
  @certification_page.attended_main_hearing.click
end

When(/^I click Certify and submit claim$/) do
  @certification_page.certify_and_submit_claim.trigger "click"
end

Then(/^I should be on the page showing basic claim information$/) do
  expect(@confirmation_page).to be_displayed
end

When(/^I click View your claims$/) do
  @confirmation_page.view_your_claims.click
end

Then(/^My new claim should be displayed$/) do
  expect(@external_user_home_page).to be_displayed
end

Then(/^I should be on the your claims page$/) do
  expect(@external_user_home_page).to be_displayed
end

Then(/^Claim '(.*?)' should be listed with a status of '(.*?)'(?: and a claimed amount of '(.*?)')?$/) do |case_number, status, claimed|
  my_claim = @external_user_home_page.claim_for(case_number)
  expect(my_claim).not_to be_nil
  expect(my_claim.state.text).to eq(status)
  expect(my_claim.claimed.text).to eq(claimed) if claimed
end

# The following steps are needed until we open the different LGFS claims
# to the general users. At the moment the options are behind a feature flag.
#
Given(/^I am allowed to submit interim claims$/) do
  allow(Settings).to receive(:allow_lgfs_interim_fees?).and_return(true)
end

Given(/^I am allowed to submit transfer claims$/) do
  allow(Settings).to receive(:allow_lgfs_transfer_fees?).and_return(true)
end

Given(/^I am not allowed to submit interim or transfer claims$/) do
  allow(Settings).to receive(:allow_lgfs_interim_fees?).and_return(false)
  allow(Settings).to receive(:allow_lgfs_transfer_fees?).and_return(false)
end

Then(/^I should see the error '(.*?)'$/) do |error_message|
  within('div.error-summary') do
    expect(page).to have_content(error_message)
  end
end

And(/^I should see the sidebar total '(.*?)'$/) do |total|
  within('div.totals-summary') do
    expect(page.find('span.total-grandTotal')).to have_content(total)
  end
end