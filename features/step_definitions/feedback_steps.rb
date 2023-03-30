When(/^I have not signed in$/) do
  visit new_user_session_path
end

Then(/^I see confirmation that my '(.*?)' was received$/) do |feedback_type|
  case feedback_type
  when 'feedback'
    expect(page).to have_govuk_notification_banner(key: :notice, text: 'Feedback submitted')
  when 'bug report'
    expect(page).to have_govuk_notification_banner(key: :notice, text: 'Fault submitted')
  end
end

Then('I see a warning that my feedback was not submitted successfully') do
  have_govuk_notification_banner(key: :error, text: /Unable to submit feedback \[\d+\]/)
end

Then('I see a warning that my bug report was not submitted successfully') do
  expect(page).to have_govuk_notification_banner(key: :error, text: /Unable to submit fault/)
end

Then(/^I should be informed that I have signed out$/) do
  expect(page).to have_content('You have signed out')
end

Then(/^I should be on the feedback page$/) do
  expect(current_path).to eq(feedback_index_path)
end

Then(/^I should be on the bug report page$/) do
  expect(current_path).to eq(feedback_index_path)
end

Then(/^I should be on the sign in page$/) do
  expect(current_path).to eq(new_user_session_path)
end
