Given(/^I visit "(.*?)"$/) do |path|
  visit path
end

When(/^show me the page$/) do
  save_and_open_page
end
