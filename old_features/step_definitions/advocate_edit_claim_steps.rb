When(/^I render the claim invalid$/) do
  fill_in 'claim_case_number', with: ''
end

When(/^I delete all fees and expenses$/) do
  Claim::BaseClaim.first.fees.destroy_all
end

Then(/^I should be redirected back and errors displayed$/) do
  expect(page.current_path).to eq(external_users_claim_path(@claim))
  expect(page).to have_content(/This claim has \d+ errors?/)
end

When(/^I remove a rep order$/) do
  page.all(:link, 'Remove representation order').last.click
end

When(/^save the claim in draft state$/) do
  click_on 'Save to drafts'
end

Then(/^the claim should have one less rep order associated$/) do
  expect(Claim::BaseClaim.last.defendants.last.representation_orders.count).to eq 1
end
