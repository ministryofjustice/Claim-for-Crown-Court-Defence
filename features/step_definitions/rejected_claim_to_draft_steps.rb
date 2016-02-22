Given(/^I am on the detail page for a "(.*?)" claim$/) do |state|
  claim = create("#{state}_claim".to_sym, external_user: @advocate)
  visit external_users_claim_path(claim)
end

Then(/^I should not see the "(.*?)" link$/) do |link_text|
  expect(current_path).to eq(external_users_claim_path(Claim::BaseClaim.last))
  expect(page).to_not have_content(link_text)
end

Given(/^I am on the detail page for a rejected claim with case number '(.+)'$/) do |case_number|
  rejected_claim = create(:rejected_claim, external_user: @advocate, case_number: case_number)
  visit external_users_claim_path(rejected_claim)
end

Then(/^I should be redirected to the edit page of a draft claim$/) do
  expect(Claim::BaseClaim.last).to be_draft
  expect(current_path).to eq(edit_external_users_claim_path(Claim::BaseClaim.last))
end

Then(/^the draft claim should have case number '(.+)'$/) do |case_number|
  expect(Claim::BaseClaim.last.case_number).to eq(case_number)
  expect(page).to have_selector("input[value='#{case_number}']")
end
