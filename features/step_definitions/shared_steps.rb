When(/^I click "(.*?)"$/) do |link_or_button|
  click_on link_or_button
end

Then(/^I should( not)? see the get in touch contact link$/) do |have|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_content("if you're having trouble with this")
  expect(page).method(to_or_not_to).call have_link("get in touch", href: contact_us_page_path)
end
