Given(/^I visit the home page$/) do
  visit root_path
end

Then(/^I should see the title "(.*?)"$/) do |title|
  expect(page).to have_content(title)
end
