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
