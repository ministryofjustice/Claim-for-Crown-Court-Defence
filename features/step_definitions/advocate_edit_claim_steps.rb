When(/^I render the claim invalid$/) do
  fill_in 'claim_case_number', with: ''
end

When(/^I delete all fees and expenses$/) do
  Claim.first.fees.destroy_all
end

Then(/^I should be redirected back and errors displayed$/) do 
  expect(page.current_path).to eq(advocates_claim_path(@claim))
  expect(page).to have_content(/This claim has \d+ errors?/)
end
