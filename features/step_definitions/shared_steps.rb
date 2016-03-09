When(/^I click "(.*?)"$/) do |link_or_button|
  click_on link_or_button
end

Then(/^I should( not)? see the get in touch contact link$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_link("report a fault here.", href: new_feedback_path(type: 'bug_report'))
end
