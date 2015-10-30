Given(/^I am on the new user page$/) do
  visit '/advocates/admin/advocates/new'
end

When(/^I fill in the details$/) do
  fill_in 'advocate_user_attributes_first_name', with: 'Harold'
  fill_in 'advocate_user_attributes_last_name', with: 'Hughes'
  fill_in 'advocate_user_attributes_email', with: 'harold.hughes@example.com'
  choose(('advocate[apply_vat]').first)
  fill_in 'advocate_supplier_number', with: '31425'
  choose(('advocate[role]').first)
end

When(/^click submit$/) do
  click_on 'Save'
end

Then(/^I see confirmation that a new user has been created$/) do
  expect(page).to have_content 'Advocate successfully created'
end
