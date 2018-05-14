Given(/^I visit "(.*?)"$/) do |path|
  visit path
end

When(/^I save and open page$/) do
  save_and_open_page
end

When(/^I save and open screenshot$/) do
  save_and_open_screenshot
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

Given(/^I click 'Your claims' link$/) do
  @external_user_home_page.your_claims_link.click
end

Then(/^I should (see|not see) '(.*)'$/) do |visibility, text|
  if (visibility == 'see')
    expect(page).to have_content(text)
  else
    expect(page).not_to have_content(text)
  end
end

Then(/^I should see a supplier number select list$/) do
  expect(@claim_form_page).to have_lgfs_supplier_number_select
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

When(/^I select the offence category '(.*?)'$/) do |offence_cat|
  @claim_form_page.select_offence_category offence_cat
end

And(/^I sleep for '(.*?)' second$/) do |num_seconds|
  sleep num_seconds.to_f
end

Given(/^I am later on the Your claims page$/) do
  @external_user_home_page.load
end

When(/I click the claim '(.*?)'$/) do |case_number|
  @external_user_home_page.claim_for(case_number).case_number.click
end

When(/I click the link '(.*?)'$/) do |text|
  expect(page).to have_link(text)
  click_link(text)
end

When(/I edit this claim/) do
  @external_user_claim_show_page.edit_this_claim.click
end

When(/^I edit the claim's case details$/) do
  @claim_summary_page.change_case_details.click
end

When(/^I edit the claim's defendants$/) do
  @claim_summary_page.change_defendants.click
end

Then(/^I should be on the certification page$/) do
  expect(@certification_page).to be_displayed
end

When(/^I check “I attended the main hearing”$/) do
  @certification_page.attended_main_hearing.click
end

When(/^I click Certify and submit claim$/) do
  allow(Aws::SNS::Client).to receive(:new).and_return Aws::SNS::Client.new(region: 'eu_west_1', stub_responses: true)
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

Then(/^I should see the error '(.*?)'$/) do |error_message|
  within('div.error-summary') do
    expect(page).to have_content(error_message)
  end
end

And(/^I should see in the sidebar total '(.*?)'$/) do |total|
  within('div.totals-summary') do
    expect(page.find('span.total-grandTotal')).to have_content(total)
  end
end


And(/^I should see in the sidebar vat total '(.*?)'$/) do |total|
  within('div.totals-summary') do
    expect(page.find('span.total-vat')).to have_content(total)
  end
end

And(/^I should be in the '(.*?)' form page$/) do |page_title|
  within('#claim-form') do
    expect(page.first('h2')).to have_content(page_title)
  end
end

# Record modes can be: all, none, new_episodes or once. Default is 'none'.
# When creating new tests that calls new endpoints, you will need to record the cassette.
# NOTE: see the README section 'Recording new VCR cassettes' for assistance
# NOTE: Never commit code that would result in VCR attempting to record a cassette
#       i.e. either cassette must exist, or you explicitly call "and record 'none'"
#
And(/^I insert the VCR cassette '(.*?)'(?: and record '(.*?)')?$/) do |name, record|
  # Caching.clear if record
  record_mode = (record || 'once').to_sym
  VCR.eject_cassette if VCR.current_cassette
  VCR.insert_cassette(name, record: record_mode)
end

And(/^I eject the VCR cassette$/) do
  VCR.eject_cassette
end
