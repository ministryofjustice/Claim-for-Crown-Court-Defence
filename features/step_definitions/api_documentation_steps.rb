require 'cucumber/rspec/doubles'

Given(/^I am( not)? on the API sandbox$/) do |negation|
  true_or_false = negation.nil? ? true : negation.gsub(/\s+/,'').downcase == 'not' ? false : true
  allow(Rails).to receive_message_chain(:host,:api_sandbox?).and_return true_or_false
end

Then(/^I should( not)? see a link to the API sign up and documentation$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_selector('a', text: 'API Sign up and Documentation')
end

Then(/^I should( not)? see a link to the API documentation$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_selector('a', text: 'API Documentation')
end

When(/^I click on the API Sign up and Documentation link$/) do
  click_link('API Sign up and Documentation')
end

Then(/^I should be directed to the API landing page$/) do
  expect(page).to have_selector('h2',text: 'Advocate Defence Payments API')
end