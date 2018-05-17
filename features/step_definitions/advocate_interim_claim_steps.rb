Then(/^I should be on the advocate interim new claim page$/) do
  expect(@advocate_interim_claim_form_page).to be_displayed
end

And(/^I fill in '(.*)' as the warrant issued date$/) do |date|
  @advocate_interim_claim_form_page.warrant_issued_date.set_date date
end

And(/^I enter a Warrant net amount of '(.*?)'$/) do |amount|
  @advocate_interim_claim_form_page.warrant_net_amount.set amount
end
