Then(/^I should see my total value of outstanding claims$/) do
  expect(page).to have_css("#summary", text: /outstanding claims\: \£#{@claims.sum(&:total)}/i)
end

# Duplicate of the step above?
Then(/^I should see the total value of outstanding claims for my chamber$/) do
  expect(page).to have_css("#summary", text: /outstanding claims\: \£#{@claims.sum(&:total)}/i)
end

Then(/^I should see my total value of authorised claims$/) do
  expect(page).to have_css("#summary", text: /authorised claims\: \£#{@claims.sum(&:total)}/i)
end

Then(/^I should see the total value of authorised claims for my chamber$/) do
  expect(page).to have_css("#summary", text: /authorised claims\: \£#{@claims.sum(&:total)}/i)
end

