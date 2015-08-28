Given(/^a case type of "(.*?)" exists$/) do |name|
  create(:case_type, name: name)
end

Then(/^I should( not)? see Cracked Trial fields$/i) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(does).call have_content('Cracked Trial Detail')
  trial_field_labels = ['Notice of 1st fixed/warned issued','1st fixed/warned trial','Case cracked','Case cracked in']
  trial_field_labels.each do |label_text|
    expect(page).method(does).call have_content(label_text)
  end
end
