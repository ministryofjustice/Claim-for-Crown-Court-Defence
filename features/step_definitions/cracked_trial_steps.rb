
Then(/^I select2 "([^"]*)" from "([^"]*)"$/) do |value, select_id|
  select2 value, from: select_id
end

Then(/^I should( not)? see Cracked Trial fields$/i) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  trial_field_labels = ['Notice of 1st fixed/warned issued','1st fixed/warned trial','Case cracked','Case cracked in']
  trial_field_labels.each do |label_text|
    expect(page).method(does).call have_content(label_text)
  end
end
