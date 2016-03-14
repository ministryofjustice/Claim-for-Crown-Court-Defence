When(/^I click '(.*?)'$/) do |link_or_button|
  click_on link_or_button
end

When(/^I fill in the '(.*?)' form$/) do |payload|
  case payload
  when 'feedback'
    fill_in 'feedback[comment]', with: 'This is great!'
    choose('Very satisfied')
    click_on 'Send'
  when 'bug report'
    fill_in 'feedback[event]', with: 'Filling in a new claim form'
    fill_in 'feedback[outcome]', with: 'Something went wrong'
    click_on 'Send'
  end
end

Then(/^I see confirmation that my '(.*?)' was received$/) do |payload|
  case payload
  when 'feedback'
    expect(page).to have_content "Feedback submitted"
  when 'bug report'
    expect(page).to have_content "Feedback submitted"
  end
end

Then(/^I should be informed that I have signed out$/) do
  expect(page).to have_content('You have signed out')
end

Then(/^I should be redirected to the feedback page$/) do
  expect(current_path).to eq(new_feedback_path)
end

Then(/^I should be on the sign in page$/) do
  expect(current_path).to eq(new_user_session_path)
end
