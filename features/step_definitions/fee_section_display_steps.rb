Then(/^I should( not)? see the (basic-fees|misc-fees|fixed-fees) section$/) do |negate, section_id|
  if negate.present?
    expect(page).to_not have_selector("##{section_id}")
  else
    expect(page).to have_selector("##{section_id}")
  end
end