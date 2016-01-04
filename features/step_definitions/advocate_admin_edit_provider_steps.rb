When(/^I visit the Edit provider page$/) do
  visit edit_advocates_admin_provider_path(@advocate.provider)
  expect(page.current_path).to eq(edit_advocates_admin_provider_path(@advocate.provider))
end

When(/^I fill in supplier number with "(.*?)"$/) do |supplier_number|
  fill_in 'provider_supplier_number', with: supplier_number
end

Then(/^I should see a supplier of "(.*?)"$/) do |supplier_number|
  expect(page).to have_content(supplier_number)
end

When(/^I visit the Manage provider page$/) do
  visit advocates_admin_provider_path(@advocate.provider)
  @api_key = find('#api-key').text
end

Then(/^I should be redirected to the Manage provider page$/) do
  expect(page.current_path).to eq(advocates_admin_provider_path(@advocate.provider))
end

Then(/^I should see a new api key$/) do
  expect(page).to have_selector('#api-key')
  new_api_key = find('#api-key').text
  expect(new_api_key).to_not eql @api_key
end
