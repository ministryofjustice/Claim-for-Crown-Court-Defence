require 'cucumber/rspec/doubles'

Given(/^I am( not)? on the API sandbox$/) do |negation|
  true_or_false = negation.nil? ? true : negation.gsub(/\s+/,'').downcase == 'not' ? false : true
  allow(Rails).to receive_message_chain(:host, :api_sandbox?).and_return true_or_false
end

Then(/^I should( not)? see a link to the API sign up and documentation$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_selector('a', text: 'API Sign up and documentation')
end

Then(/^I should( not)? see a link to the API documentation$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_selector('a', text: 'API Documentation')
end

When(/^I click on the API Sign up and Documentation link$/) do
  click_link('API Sign up and documentation')
end

Then(/^I should be directed to the API landing page$/) do
  expect(find('.main-header')).to have_content('Claim for crown court defence API')
end

When(/^I visit the Interactive API Documentation page$/) do
  steps <<-STEPS
     When I visit the advocates dashboard
     Then I should see a link to the API documentation
      And I click the link to the API documention
      And I click the link to the Interactive API Documentation
     Then I should be directed to the Interactive API Documentation
  STEPS
end

When(/^I click the link to the API documention$/) do
  click_link('API Documentation')
end

When(/^I click the link to the Interactive API Documentation$/) do
  click_link('Interactive API')
end

Then(/^I should be directed to the Interactive API Documentation$/) do
  expect(find('.main-header')).to have_content('Interactive API Documentation')
end

When(/^It should be styled to ADP GDS standards$/) do
  expect(find('.main-header')).to have_content('Interactive API Documentation')
  expect(find('strong.phase-tag')).to have_content(Rails.configuration.send(:phase))
  node = find('#logo').find('img')['src']
  expect(node).to have_content('moj_logo_horizontal_36x246_for_swagger.png')
end
