When('an external provider exists') do
  user = create(:user, email: 'test.user@chambers.com')
  create(:external_user, :advocate_and_admin, user: user)
end

When("I set the provider name to {string}") do |name|
  @new_provider_page.name.set name
end

When("I set the provider type to {string}") do |type|
  @new_provider_page.choose(type)
end

When('I select the {string} fee scheme') do |fee_scheme|
  @new_provider_page.fee_schemes.check(fee_scheme)
end

When("I click the Save details button") do
  @new_provider_page.save_details.click
end

When('I enter {string} in the email field') do |email|
  @provider_search_page.email.set email
end

When("I click the search button") do
  @provider_search_page.search.click
end

Then(/^I should be on the provider index page$/) do
  expect(@provider_index_page).to be_displayed
end

Then(/^I should be on the new provider page$/) do
  expect(@new_provider_page).to be_displayed
end

Then(/^I should be on the provider search page$/) do
  expect(@provider_search_page).to be_displayed
end
