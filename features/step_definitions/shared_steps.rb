When(/^I click "(.*?)"$/) do |link_or_button|
  click_on link_or_button
end

Then(/^I should( not)? see the get in touch contact link$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_link("Is there anything wrong with this service?", href: new_bug_report_path)
end
