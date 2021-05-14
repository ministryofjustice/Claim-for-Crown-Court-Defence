# frozen_string_literal: true

When('I visit the fee scheme selector page') do
  @fee_scheme_selector.load
end

Then('I am on the fee scheme selector page') do
  expect(@fee_scheme_selector).to be_displayed
end

And(/^I select the fee scheme '(.*)'$/) do |fee_scheme|
  method_name = fee_scheme.downcase.gsub(' ', '_').gsub('warrant','interim').to_sym
  @fee_scheme_selector.send(method_name).click
  @fee_scheme_selector.continue.click
end
