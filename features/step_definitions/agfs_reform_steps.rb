Then(/^the offence should have moved from '(.*)' to '(.*)'$/) do |not_see, see|
  expect(page).not_to have_content(not_see)
  expect(page).to have_content(see)
end

