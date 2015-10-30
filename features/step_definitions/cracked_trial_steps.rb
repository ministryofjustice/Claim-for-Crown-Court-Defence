Given(/^a case type of "(.*?)" exists$/) do |name|
  if name == 'Cracked Trial'
    create(:case_type, name: 'Cracked Trial', requires_cracked_dates: true)
  else
    create(:case_type, name: name)
  end
end

Then(/^I should( not)? see Cracked Trial fields$/i) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(does).call have_content('Cracked trial detail')
  trial_field_labels = ['Notice of 1st fixed/warned issued','1st Fixed/warned trial','Case cracked','Case cracked in']
  trial_field_labels.each do |label_text|
    expect(page).method(does).call have_content(label_text)
  end
end


# Then(/^I should find cracked details on the page$/) do
#   puts ">>>>>>>>>>>>>>>> DEBUG message    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
#   ap CaseType.all
#   puts ">>>>>>>>>>>>>>>> DEBUG message    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
#   expect(page).to have_content('Cracked trial detail')
#   trial_field_labels = ['Notice of 1st fixed/warned issued','1st fixed/warned trial','Case cracked','Case cracked in']
#   trial_field_labels.each do |label_text|
#     expect(page).to have_content(label_text)
#   end
# end