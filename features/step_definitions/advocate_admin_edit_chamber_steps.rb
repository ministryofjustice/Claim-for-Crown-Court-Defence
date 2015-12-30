# When(/^I visit the Edit chamber page$/) do
#   visit edit_advocates_admin_chamber_path(@advocate.chamber)
#   expect(page.current_path).to eq(edit_advocates_admin_chamber_path(@advocate.chamber))
# end
#
# When(/^I fill in supplier number with "(.*?)"$/) do |supplier_number|
#   fill_in 'chamber_supplier_number', with: supplier_number
# end
#
# Then(/^I should see a supplier of "(.*?)"$/) do |supplier_number|
#   expect(page).to have_content(supplier_number)
# end
#
#
# When(/^I visit the Manage chamber page$/) do
#   visit advocates_admin_chamber_path(@advocate.chamber)
#   @api_key = find('#api-key').text
# end
#
# Then(/^I should be redirected to the Manage chamber page$/) do
#   expect(page.current_path).to eq(advocates_admin_chamber_path(@advocate.chamber))
# end
#
# Then(/^I should see a new api key$/) do
#   expect(page).to have_selector('#api-key')
#   new_api_key = find('#api-key').text
#   expect(new_api_key).to_not eql @api_key
# end
