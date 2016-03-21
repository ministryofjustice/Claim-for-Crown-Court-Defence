Then(/^I should be redirected to the claim scheme choice page$/) do
  expect(page.current_path).to eq(types_external_users_claims_path)
end