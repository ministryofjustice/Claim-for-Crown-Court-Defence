Given(/^I am on the detail page for a "(.*?)" claim$/) do |state|
  claim = create("#{state}_claim".to_sym, advocate: @advocate)
  visit advocates_claim_path(claim)
end

Then(/^I should not see the "(.*?)" link$/) do |link_text|
  expect(current_path).to eq(advocates_claim_path(Claim.last))
  expect(page).to_not have_content(link_text)
end

Given(/^I am on the detail page for a rejected claim with case number '(.+)'$/) do |case_number|
  rejected_claim = create(:rejected_claim, advocate: @advocate, case_number: case_number)
  visit advocates_claim_path(rejected_claim)
end

Then(/^I should be redirected to the edit page of a draft claim$/) do
  expect(Claim.last).to be_draft
  expect(current_path).to eq(edit_advocates_claim_path(Claim.last))
end

Then(/^the draft claim should have case number '(.+)'$/) do |case_number|
  expect(Claim.last.case_number).to eq(case_number)
  expect(page).to have_selector("input[value='#{case_number}']")
end
