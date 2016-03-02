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
  trial_field_labels = ['Notice of 1st fixed/warned issued','1st fixed/warned trial','Case cracked','Case cracked in']
  trial_field_labels.each do |label_text|
    expect(page).method(does).call have_content(label_text)
  end
end

Then(/^I fill in cracked trial dates$/) do
  fill_in "claim_trial_fixed_notice_at_dd", with: '22'
  fill_in "claim_trial_fixed_notice_at_mm", with: '05'
  fill_in "claim_trial_fixed_notice_at_yyyy", with: '2015'
  fill_in "claim_trial_fixed_at_dd", with: '23'
  fill_in "claim_trial_fixed_at_mm", with: '05'
  fill_in "claim_trial_fixed_at_yyyy", with: '2015'
  fill_in "claim_trial_cracked_at_dd", with: '24'
  fill_in "claim_trial_cracked_at_mm", with: '05'
  fill_in "claim_trial_cracked_at_yyyy", with: '2015'
end