Given(/^I visit "(.*?)"$/) do |path|
  visit path
end

When(/^show me the page$/) do
  save_and_open_page
end

When(/^I start a claim/) do
  find('.primary-nav-bar').click_link('Start a claim')
end
