When(/^I render the claim invalid$/) do
  fill_in 'claim_case_number', with: ''
end

Then(/^I should be redirected back and errors displayed$/) do
  expect(page.current_path).to eq(advocates_claim_path(@claim))
  expect(page).to have_content(/\d+ errors? prohibited this claim from being saved:/)
end