Then(/^I choose radio button "(.*?)"$/) do |id_or_label|
  choose id_or_label
end

Then(/^I should (not )?see summary error "(.*?)"$/) do |negate, error_message|
  if negate
    expect(page).to_not have_selector('a', text: error_message)
  else
    expect(page).to have_selector('a', text: error_message)
  end
end
