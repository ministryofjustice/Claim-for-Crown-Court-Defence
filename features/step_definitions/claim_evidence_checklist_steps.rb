Given(/^evidence checklist entries exist$/) do
  @first_eli = create(:evidence_list_item, description: 'Evidence list item 1')
end

Then(/^I should see an evidence checklist section$/) do
  expect(page).to have_selector('fieldset#evidence-checklist')
end

Then(/^I check the first checkbox$/) do
  check @first_eli.description
end

Then(/^I visit the claim show page$/) do
  @claim = @claim || Claim.first
  visit advocates_claim_path(@claim)
end

Then(/^I should see a list item for "(.*?)" evidence$/) do |text|
  expect(page).to have_selector('li', text: text)
end
