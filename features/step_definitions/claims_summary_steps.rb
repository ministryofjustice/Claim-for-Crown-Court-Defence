Then(/^I should see my total value of outstanding claims$/) do
  expect(page).to have_css("#summary #outstanding_claims")
end

Then(/^I should see the total value of outstanding claims for my chamber$/) do
  expect(page).to have_css("#summary #outstanding_claims")
end

Then(/^I should see my total value of authorised claims$/) do
  expect(page).to have_css("#summary #authorised_claims")
end

Then(/^I should see the total value of authorised claims for my chamber$/) do
  expect(page).to have_css("#summary #authorised_claims")
end

