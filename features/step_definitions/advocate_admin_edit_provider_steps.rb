When(/^I visit the Edit provider page$/) do
  visit edit_external_users_admin_provider_path(@advocate.provider)
  expect(page.current_path).to eq(edit_external_users_admin_provider_path(@advocate.provider))
end

When(/^I fill in supplier number with "(.*?)"$/) do |supplier_number|
  fill_in 'provider_supplier_number', with: supplier_number
end

Then(/^I should see a supplier of "(.*?)"$/) do |supplier_number|
  expect(page).to have_content(supplier_number)
end

Then(/^I should not see a supplier number$/) do
  expect(page).to_not have_content(/Supplier number/i)
end

When(/^I visit the Manage provider page$/) do
  visit external_users_admin_provider_path(@advocate.provider)
  @api_key = find('#api-key').text
end

Then(/^I should be redirected to the Manage provider page$/) do
  expect(page.current_path).to eq(external_users_admin_provider_path(@advocate.provider))
end

Then(/^I should see a new api key$/) do
  expect(page).to have_selector('#api-key')
  new_api_key = find('#api-key').text
  expect(new_api_key).to_not eql @api_key
end

Given(/^my provider is a "(.*?)"$/) do |provider_type|
  @advocate.provider.update_column(:provider_type, provider_type)
  @advocate.provider.update_column(:vat_registered, false)
end

Then(/^I should (not )?see the supplier number field$/) do |negate|
  if negate.present?
    expect(page).to_not have_selector('#provider_supplier_number')
  else
    expect(page).to have_selector('#provider_supplier_number')
  end
end

When(/^I choose "(.*?)" for VAT registration$/) do | vat_registered |
  choose vat_registered
end

Then(/^I should (not )?see VAT registration status of "(.*?)"$/) do |negate, value|
  if negate.present?
    expect(page).to_not have_content(/VAT registered/i)
  else
    expect(page).to have_content(/VAT registered #{value}/i)
  end
end

Then(/^I should not see the VAT registration checkbox$/) do
  expect(page).to_not have_selector('#provider_vat_registered')
end

Then(/^I should not see VAT registration information$/) do
  expect(page).to_not have_content(/VAT registered/i)
end
